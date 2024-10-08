#!/bin/bash

# Load base config
source configs/.env

# Instance specific configs
PROJECT_NAME=bento-gdi                                   # Name of the project/instance
DATA_VOLUME_SIZE=500                           # /data volume size in GB
APP_VOLUME_SIZE=100                             # /app volume size in GB
FLAVOR="ha8-30gb"                               # Openstack flavor for compute resources
IMAGE=$ROCKY_9_3_IMAGE_UUID
