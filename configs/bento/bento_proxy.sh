#!/bin/bash

# Load global SD4H variables (e.g. OS UUIDs)
source configs/sd4h.env

# Load Bento project specific OpenStack config
source configs/bento/.env

# Instance specific configs
export PROJECT_NAME="bento-proxy"                 # Name of the project/instance
DATA_VOLUME_SIZE=                           # /data volume size in GB
APP_VOLUME_SIZE=10                             # /app volume size in GB
FLAVOR="ha2-7.5gb"                               # Openstack flavor for compute resources
IMAGE=$ROCKY_9_3_IMAGE_UUID
DOCKER_VOLUME_SIZE=15
