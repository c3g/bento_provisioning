#!/bin/bash

# Load base config
source configs/.env

# Instance specific configs
PROJECT_NAME=bento-ichange
DATA_VOLUME_SIZE=5000           # /data volume size in GB
APP_VOLUME_SIZE=200             # /data volume size in GB
FLAVOR="ha8-30gb"               # Openstack flavor for compute resources
IMAGE="f95b59a2-99fd-4b7f-912c-d7f17640a791"    # Rocky 9,3
