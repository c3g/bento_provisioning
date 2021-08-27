PROJECT_NAME=ichange
DATA_VOLUME_SIZE=5000 # 5TB
FLAVOR=p4-6gb
IMAGE=CentOS-7-x64-2020-11
LAN_ID=9ddbf1b2-a335-470b-a5b3-d3e4bd2b91cc

openstack volume create --size ${DATA_VOLUME_SIZE} ${PROJECT_NAME}-data
openstack volume create --size 20 ${PROJECT_NAME}-docker-sandbox
openstack server create --key-name "poq sur moins" --flavor  ${FLAVOR} --image ${IMAGE} \
  --nic net-id=${LAN_ID} --security-group default  \
  --security-group bento-dev  --boot-from-volume 8  \
  --user-data bento_v2_${PROJECT_NAME}.yaml   \
  --block-device-mapping vdb=${PROJECT_NAME}-data  \
  --block-device-mapping vdc=${PROJECT_NAME}-docker-sandbox \
  ${PROJECT_NAME}

SERVER_ID=$(openstack server list -f json |  jq -r   '.[] | select((."Name"=="ichange")).ID')

ip=$(openstack  floating ip list   -f json | jq -r '.[] | select(."Fixed IP Address"==null)."Floating IP Address"')

if [ -z "${ip}" ]; then
  openstack  floating ip create external-network
  ip=$(openstack  floating ip list   -f json | jq -r '.[] | select(."Fixed IP Address"==null)."Floating IP Address"')
fi

openstack server add floating ip  ${PROJECT_NAME} ${ip}
