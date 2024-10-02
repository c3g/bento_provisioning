#!/bin/bash

# Load base config
source configs/bento/.env

# Instance specific configs
PROJECT_NAME=moh-bento
DATA_VOLUME_SIZE=100
APP_VOLUME_SIZE=20
FLAVOR="ha4-15gb"
IMAGE=$ROCKY_9_3_IMAGE_UUID
