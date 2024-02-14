#!/bin/bash

# Load base config
source configs/.env

# Instance specific configs
PROJECT_NAME=bento-rocky-test                                   # Name of the project/instance
DATA_VOLUME_SIZE=5                           # /data volume size in GB
APP_VOLUME_SIZE=5                             # /app volume size in GB
FLAVOR="ha4-15gb"                               # Openstack flavor for compute resources
IMAGE=$ROCKY_9_3_IMAGE_UUID
