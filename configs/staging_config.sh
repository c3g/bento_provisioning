#!/bin/bash

# Load base config
source configs/.env

# Instance specific configs
PROJECT_NAME=bento-staging
DATA_VOLUME_SIZE=1000
APP_VOLUME_SIZE=200             # /data volume size in GB
FLAVOR="ha4-15gb"
IMAGE="f95b59a2-99fd-4b7f-912c-d7f17640a791" # Rocky 9,3
