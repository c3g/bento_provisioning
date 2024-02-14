#!/bin/bash

# Load base config
source configs/.env

# Instance specific configs
PROJECT_NAME=bento-renata
DATA_VOLUME_SIZE=50
APP_VOLUME_SIZE=50
FLAVOR="ha4-15gb"
IMAGE=$ROCKY_9_3_IMAGE_UUID
