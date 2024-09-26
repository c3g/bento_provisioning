#!/usr/bin/env bash

# Run this script on a VM to install desired docker compose plugin version from binaries

# V2.29.7
COMPOSE_RELEASE="https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64"

# Dir setup
PLUGINS_DIR=$HOME/.docker/cli-plugins
COMPOSE_DIR=$PLUGINS_DIR/docker-compose
mkdir -p $PLUGINS_DIR

# Download binaries
curl -L $COMPOSE_RELEASE -o $COMPOSE_DIR

sudo chmod +x $COMPOSE_DIR

docker compose version
