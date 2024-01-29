#!/bin/bash

# Load base config
source configs/.env

# Instance specific configs
PROJECT_NAME=bento-ichange
DATA_VOLUME_SIZE=5000           # /data volume size in GB
FLAVOR="ha8-30gb"               # Openstack flavor for compute resources
IMAGE="Rocky-8.9-x64-2023-11"   # Instance operating system source image
