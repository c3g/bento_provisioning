#!/bin/bash

usage (){
echo ""
echo "usage: $0 <project config>"
echo "    Deploy a bento node with root, data and docker volumes"
echo "    <project config> the path to the project configuration file."
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

if [ $# -ne 1 ] ; then
   usage 
   exit 1
fi
PROJECT_CONFIG_FILE=$1
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
YAML_CONFIG=.tmp/bento_${PROJECT_NAME}.yaml
BENTO_HOSTNAME=${PROJECT_NAME} envsubst  '${BENTO_HOSTNAME}' \
< template_bento.yaml > $YAML_CONFIG

# TODO check if the volume exist already instead of a having a flag
 if [ -z ${NO_VOLUME+x} ]; then
  openstack volume create --size ${DATA_VOLUME_SIZE} ${PROJECT_NAME}-data
  openstack volume create --size 20 ${PROJECT_NAME}-docker-sandbox
fi

openstack server create --key-name ${SSH_KEY} --flavor  ${FLAVOR} \
  --image ${IMAGE} \
  --nic net-id=${LAN_ID} --security-group default  \
  --security-group ${SECURITY_GROUP}  --boot-from-volume ${ROOT_VOLUME_SIZE}  \
  --user-data  ${YAML_CONFIG}  \
  --block-device-mapping vdb=${PROJECT_NAME}-data  \
  --block-device-mapping vdc=${PROJECT_NAME}-docker-sandbox \
  ${PROJECT_NAME}

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
