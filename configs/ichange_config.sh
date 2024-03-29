#!/bin/bash

# Load base config
source configs/.env

# Instance specific configs
PROJECT_NAME=bento-ichange
DATA_VOLUME_SIZE=5000           # /data volume size in GB
APP_VOLUME_SIZE=1000             # /data volume size in GB
FLAVOR="ha8-30gb"               # Openstack flavor for compute resources
IMAGE=$ROCKY_9_3_IMAGE_UUID
