#!/bin/bash

usage (){
echo ""
echo "usage: $0 <project-config-file> $1 <cloud-init-template>"
echo "    Deploy a bento node with root, data and docker volumes"
echo "    <project-config-file> the path to the project configuration file."
echo "    <cloud-init-template> the path to the cloud-init template file"
echo "options"
echo "    -n        DO not create the volume to mount"

}
while getopts ":hn" opt; do
  case $opt in
  n)
        NO_VOLUME=True
        ;;
  h)
      usage
      exit 0
      ;;
   \?)
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))
# move the exec line to a script

if [ $# -ne 2 ] ; then
   usage 
   exit 1
fi
PROJECT_CONFIG_FILE=$1
CLOUD_INIT_TEMPLATE=$2
while true; do

source $PROJECT_CONFIG_FILE

read -p "The project name is : $PROJECT_NAME (y/n) " yn

case $yn in 
	[yY] ) echo proceeding with $PROJECT_NAME;
		break;;
	* ) echo refusing;
               exit 1;;
esac

done

mkdir -p .tmp/
CLOUD_INIT_CONFIG=.tmp/${PROJECT_NAME}.yaml

# Replace environment variables in the template file to create the final cloud-init config
#   - User names 
#   - Public SSH keys
#   - Hostname
envsubst '$NODE_ADMIN_USER,$APP_ADMIN_USER,$DATA_USER,$NODE_ADMIN_USER_PUBKEYS,$APP_ADMIN_USER_PUBKEYS,$DATA_USER_PUBKEYS,$PROJECT_NAME' \
 < ${CLOUD_INIT_TEMPLATE} > $CLOUD_INIT_CONFIG

BLOCK_DEVICE_PARAMS=()
create_volume_if_needed ()
{
  volume_name=$1
  volume_size=$2
  volume_type=$3
  volume_device=$4

  if [ -z $volume_size ]; then
    echo "   Skipping creation of '${volume_name}', size is not configured."
    return
  fi
  
  existing_id=$(openstack volume list -f json | jq '.[] | select((."Name"=="'${volume_name}'")).ID')
  if [ -z ${existing_id} ]; then
    openstack volume create --type ${volume_type} --size ${volume_size} ${volume_name}
  else
    echo "   Volume '${volume_name}' already exists with id '${existing_id}', skipping creation."
  fi

  # Add volume to the list of block devices args to mount to the server
  block_device_param="--block-device-mapping ${volume_device}=${volume_name}"
  BLOCK_DEVICE_PARAMS+=($block_device_param)
}

if [ -z ${NO_VOLUME+x} ]; then
  # create the data volume (EC) if the size is set
  create_volume_if_needed ${PROJECT_NAME}-data "${DATA_VOLUME_SIZE}" volumes-ec vdb
  # create app volume (SSD) if the size is set
  create_volume_if_needed ${PROJECT_NAME}-app "${APP_VOLUME_SIZE}" volumes-ssd vdd
  # create a volume for Docker if the size is set
  create_volume_if_needed ${PROJECT_NAME}-docker-sandbox "${DOCKER_VOLUME_SIZE}" volumes-ssd vdc
fi

openstack server create --key-name ${SSH_KEY} --flavor  ${FLAVOR} \
  --image ${IMAGE} \
  --nic net-id=${LAN_ID} --security-group default  \
  --security-group ${SECURITY_GROUP}  --boot-from-volume ${ROOT_VOLUME_SIZE}  \
  --user-data  ${CLOUD_INIT_CONFIG}  \
  "${BLOCK_DEVICE_PARAMS[@]}" \
  ${PROJECT_NAME}

  # --block-device-mapping vdb=${PROJECT_NAME}-data  \
  # --block-device-mapping vdd=${PROJECT_NAME}-app \
  # --block-device-mapping vdc=${PROJECT_NAME}-docker-sandbox \

SERVER_ID=$(openstack server list -f json \
    |  jq -r   '.[] | select((."Name"=="'${PROJECT_NAME}'")).ID')


# get one floating ip
ip=$(openstack  floating ip list   -f json \
    | jq -r '[.[] | select(."Fixed IP Address"==null)][0]."Floating IP Address"')

# create one if there is not one free
if [ "${ip}"  == "null" ]; then
  openstack  floating ip create ${PUBLIC_NETWORK_ID}
  ip=$(openstack  floating ip list   -f json \
    | jq -r '.[] | select(."Fixed IP Address"==null)."Floating IP Address"')
fi

while ! openstack server show  -f json ${PROJECT_NAME} | jq -r '.status ' | grep 'ACTIVE'
do
  echo waiting for build to complete
  sleep 2
done

openstack server add floating ip  ${PROJECT_NAME} ${ip}

# adding name to root volume (server take some time before mount is visible)
VOLUME_ROOT=$(openstack volume list -f json  \
| jq -r   '.[] | select((."Attached to"[]."device"=="/dev/vda" and ."Attached to"[]."server_id"=="'${SERVER_ID}'")).ID')
openstack volume set --name ${PROJECT_NAME}-root $VOLUME_ROOT
