#!/bin/bash

# This config template can be used on any OpenStack project, 
# provided that you fill in the correct project-specific UUIDs from OpenStack.

# Load global SD4H variables (e.g. OS UUIDs)
source configs/sd4h.env

#### OpenStack project specific configs
SSH_KEY=""                      # OpenStack key pair NAME
LAN_ID=""                       # OpenStack LAN network UUID
PUBLIC_NETWORK_ID=""            # OpenStack Public-Network UUID
SECURITY_GROUP=""               # OpenStack security group UUID
ROOT_VOLUME_SIZE=10

#### Instance specific configs
export PROJECT_NAME=""          # Name of the instance
DATA_VOLUME_SIZE=1000           # /data volume size in GB
APP_VOLUME_SIZE=200             # /app volume size in GB
DOCKER_VOLUME_SIZE=20           # Docker volume size in GB
FLAVOR="ha4-15gb"               # Openstack flavor for compute resources (CPUs, RAM)
IMAGE=""                        # OpenStack OS image UUID

#### User configurations
export NODE_ADMIN_USER=admin            # Admin user name
export NODE_ADMIN_USER_PUBKEYS="[]"     # comma separated public keys for admin

export APP_ADMIN_USER=app-operator      # user with /app access, docker, sudo
export APP_ADMIN_USER_PUBKEYS="[]"      # comma separated public keys for app operator

export DATA_USER=data-operator          # user with /data access
export DATA_USER_PUBKEYS="[]"           # comma separated public keys for data operator
