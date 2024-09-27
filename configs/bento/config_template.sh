#!/bin/bash

# Load Bento project specific OpenStack config
source configs/bento/.env

# Instance specific configs
export PROJECT_NAME=                                   # Name of the project/instance
DATA_VOLUME_SIZE=1000                           # /data volume size in GB
APP_VOLUME_SIZE=200                             # /app volume size in GB
FLAVOR="ha4-15gb"                               # Openstack flavor for compute resources
IMAGE=$ROCKY_9_3_IMAGE_UUID
DOCKER_VOLUME_SIZE=20
