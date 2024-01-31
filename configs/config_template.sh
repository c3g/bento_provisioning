#!/bin/bash

# Load base config
source configs/.env

# Instance specific configs
PROJECT_NAME=                                   # Name of the project/instance
DATA_VOLUME_SIZE=1000                           # /data volume size in GB
APP_VOLUME_SIZE=200                             # /app volume size in GB
FLAVOR="ha4-15gb"                               # Openstack flavor for compute resources
IMAGE=$ROCKY_9_3_IMAGE_UUID
