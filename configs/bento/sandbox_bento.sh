#!/bin/bash

# Load base config
source configs/bento/.env

# Instance specific configs
export PROJECT_NAME=bento-sandbox                      # Name of the project/instance
DATA_VOLUME_SIZE=                           # /data volume size in GB
APP_VOLUME_SIZE=50                             # /app volume size in GB
FLAVOR="ha2-7.5gb"                               # Openstack flavor for compute resources
IMAGE=$ROCKY_9_3_IMAGE_UUID
DOCKER_VOLUME_SIZE=20
