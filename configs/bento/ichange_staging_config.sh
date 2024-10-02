#!/bin/bash

# Load base config
source configs/bento/.env

# Instance specific configs
PROJECT_NAME=bento-ichange-staging
DATA_VOLUME_SIZE=2000           # /data volume size in GB
APP_VOLUME_SIZE=1000             # /data volume size in GB
FLAVOR="ha4-15gb"               # Openstack flavor for compute resources
IMAGE=$ROCKY_9_3_IMAGE_UUID
