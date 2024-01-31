#!/bin/bash

# Load base config
source configs/.env

# Instance specific configs
PROJECT_NAME=bento-staging
DATA_VOLUME_SIZE=1000
APP_VOLUME_SIZE=200             # /data volume size in GB
FLAVOR="ha4-15gb"
IMAGE=$ROCKY_9_3_IMAGE_UUID
