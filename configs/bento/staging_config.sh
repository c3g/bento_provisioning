#!/bin/bash

# Load base config
source configs/bento/.env

# Instance specific configs
PROJECT_NAME=bento-staging
DATA_VOLUME_SIZE=1000
APP_VOLUME_SIZE=200
FLAVOR="ha4-15gb"
IMAGE=$ROCKY_9_3_IMAGE_UUID
