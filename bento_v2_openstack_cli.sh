#!/bin/bash

# DO that in options?
PROJECT_NAME=bqc19
DATA_VOLUME_SIZE=3000 # 3TB
FLAVOR=p8-12gb
IMAGE=Rocky-8-x64-2021-06
LAN_ID=9ddbf1b2-a335-470b-a5b3-d3e4bd2b91cc

DOCKER_VOLUME_SIZE=20
ROOT_VOLUME_SIZE=10


usage (){
echo "usage: $0 Deploy a bento node with root, data and docker volumes"
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

mkdir -p .tmp/
YAML_CONFIG=.tmp/bento_v2_${PROJECT_NAME}.yaml
cp template_bento_v2.yaml $YAML_CONFIG
# BENTO_HOSTNAME=${PROJECT_NAME} envsubst < template_bento_v2.yaml \
    # > $YAML_CONFIG

# TODO check if the volume exist already instead of a having a flag
 if [ -z ${NO_VOLUME+x} ]; then
  openstack volume create --size ${DATA_VOLUME_SIZE} ${PROJECT_NAME}-data
  openstack volume create --size 20 ${PROJECT_NAME}-docker-sandbox
fi

openstack server create --key-name "poq sur moins" --flavor  ${FLAVOR} \
  --image ${IMAGE} \
  --nic net-id=${LAN_ID} --security-group default  \
  --security-group bento-dev  --boot-from-volume ${ROOT_VOLUME_SIZE}  \
  --user-data  ${YAML_CONFIG}  \
  --block-device-mapping vdb=${PROJECT_NAME}-data  \
  --block-device-mapping vdc=${PROJECT_NAME}-docker-sandbox \
  ${PROJECT_NAME}

SERVER_ID=$(openstack server list -f json \
    |  jq -r   '.[] | select((."Name"=="'${PROJECT_NAME}'")).ID')

# get one floating ip
ip=$(openstack  floating ip list   -f json \
    | jq -r '[.[] | select(."Fixed IP Address"==null)][0]."Floating IP Address"')

# create one if it os empty
if [ -z "${ip}" ]; then
  openstack  floating ip create external-network
  ip=$(openstack  floating ip list   -f json \
    | jq -r '.[] | select(."Fixed IP Address"==null)."Floating IP Address"')
fi

while ! openstack server show  -f json ichange | jq -r '.status ' | grep 'ACTIVE'
do
  echo waiting for build to complete
  sleep 2
done

openstack server add floating ip  ${PROJECT_NAME} ${ip}
