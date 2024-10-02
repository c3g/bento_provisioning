#!/bin/bash

# Load base config
source configs/bento/.env

# Instance specific configs
PROJECT_NAME=TEEXplorer                                   # Name of the project/instance
DATA_VOLUME_SIZE=25                           # /data volume size in GB
APP_VOLUME_SIZE=50                             # /app volume size in GB
FLAVOR="ha16-60gb"                               # Openstack flavor for compute resources
IMAGE=$ROCKY_9_3_IMAGE_UUID
