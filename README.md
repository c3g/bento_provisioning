# SD4H provisioning tools

This repository contains tools and documentation required to deploy a virtual machine (VM) on the SD4H cloud with OpenStack.
For SD4H specific operations, you must be the member of an SD4H OpenStack project.

Outside of the SD4H platform, you can use the [bento_rocky.yaml](./cloud-init-templates/bento_rocky.yaml) 
cloud-init file to initialize a Rocky Linux VM for Bento in the platform of your choice.

## Cloud-Init

This repository uses [cloud-init](https://cloudinit.readthedocs.io/en/latest/) to perform instance initialization.
The templates for cloud-init can be found in [cloud-init-templates](./cloud-init-templates):
-   [bento_rocky.yaml](./cloud-init-templates/bento_rocky.yaml): for VMs hosting a [Bento](https://github.com/bento-platform/bento) deployment
-   [generic_rocky.yaml](./cloud-init-templates/generic_rocky.yaml): for a simple Rocky Linux VM

In these templates, we define the following:
- Users
  - Permissions
  - Public SSH keys
- Packages
- Repositories
- Setup disks, filesystem, and mount points
- Initial command to run on first boot
  - Set directory ownership/group
  - Install/build software from source
  - Start systemctl services (e.g. Docker, NGINX)

## Requirements

### OpenStack CLI

Install the OpenStack CLI using the official [documentation](https://docs.openstack.org/newton/user-guide/common/cli-install-openstack-command-line-clients.html).
This CLI is used to manage resources in the OpenStack cloud.
### OpenStack auth file

The OpenStack cloud is protected by authentication. If you have a valid account, login to the OpenStack instance in a browser.
Once logged-in, you need to click on your account in the top-right corner and select the `OpenStack RC File` button.

Note: Make sure you are in the OpenStack project where you want the VM deployed, RC files are project specific.

![OpenStack RC File download button](./docs/openstack-rc-file.png)

You can then open a terminal window and source the file in order to load the necessary variables for OpenStack CLI authentication.

```bash
# For  Bento, load auth variables for the Bento project
source Bento-openrc.sh

# For other projects, authenticate your terminal to another project in SD4H
source <Other project RC file>

# Will prompt you for your password
openstack server list
```


## Create a VM

### Prepare the resources config

Create a new resources configuration file from the template.

```bash
# For a generic Rocky VM in any OpenStack project
cp configs/rocky/config_template.sh configs/rocky/<instance>_config.sh

# For a Bento VM on the Bento OpenStack project
cp configs/bento/config_template.sh configs/bento/<instance>_config.sh
```

In the `<instance>_config.sh` file you just created, modify the values for the project's name
, data volume size, flavor and OS image accordingly.

**For a Bento specific instance, you only need to set the following:**
```bash
# Instance specific configs
export PROJECT_NAME=bento-staging
DATA_VOLUME_SIZE=1000
APP_VOLUME_SIZE=200
FLAVOR="ha4-15gb"
IMAGE=$ROCKY_9_3_IMAGE_UUID # UUID loaded from .configs/.env
DOCKER_VOLUME_SIZE=20
```

**For a generic Rocky instance, you need to set the same variables as above
, plus others that are specific to the targeted OpenStack project.**
```bash
#### OpenStack project specific configs
SSH_KEY=""                      # OpenStack key pair NAME
LAN_ID=""                       # OpenStack LAN network UUID
PUBLIC_NETWORK_ID=""            # OpenStack Public-Network UUID
SECURITY_GROUP=""               # OpenStack security group UUID
ROOT_VOLUME_SIZE=10

# user name for the administrator
export NODE_ADMIN_USER=admin
# authorized public keys to login as NODE_ADMIN_USER
export NODE_ADMIN_USER_PUBKEYS="[\
<content of NODE_ADMIN .pub key 1>,\
<content of NODE_ADMIN .pub key 2>,\
]"

# user name for the applications administrator
export APP_ADMIN_USER=app-operator
export APP_ADMIN_USER_PUBKEYS="[<content of APP_ADMIN .pub key 1>]"

# user with /data access
export DATA_USER=data-operator
export DATA_USER_PUBKEYS="[]"
```

With the configuration above, we will have the following users setup:
- `admin`: A user can SSH as `admin` if he has one of the 2 provided keys
- `app-operator`: A user can SSH as `app-operator` if he has the provided key
- `data-operator`: No one can SSH as `data-operator`, may be added later if needed.

### Initialize the server on OpenStack

The `init_sd4h_vm.sh` script can be used to quickly create a new VM on SD4h.
It uses the `openstack` cli to create the server (VM) with required volumes and network interfaces.

The script takes 2 positional arguments:
1. config file path: the path to the `<instance>_config.sh` you created
2. cloud-init file path: the path the cloud-init file you wish to use

Usage example:

```bash
# Lauch the node creation script with a config argument

# For a Bento instance
bash init_sd4h_vm.sh configs/bento/<instance>_config.sh cloud-init-templates/bento_rocky.yaml

# For a generic Rocky instance
bash init_sd4h_vm.sh configs/rocky/<instance>_config.sh cloud-init-templates/generic_rocky.yaml

# The script will ask to validate the project's name from the config

# If all went well, you should see the new instance
openstack server list

# If your ssh key is listed in cloud-init-bento.yaml and the server has a floating IP, you can ssh with:
ssh bento@<floating-ip>
```


#### Security group for SSH

In order to be able to establish an SSH connection on a VM, it must have a security group that allows TCP ingress on port 22.

You can create and add security groups to servers in the OpenStack GUI, or with the openstack CLI tool.
```bash
# Create a security group with the required SSH ingress rule
openstack security group rule create <secgroup> --protocol tcp --dst-port 22 --ingress --remote-ip <CIDR>
openstack server add security group <server> <secgroup>
```

#### Security group for Bastion

TODO: add configs and docs to create Bastion-ready ready instances with no floating-ip

#### Deploy software on the VM!

Now that we have a server you can SSH on, we can deploy software on it!

See the [Bento deployment guide](./docs/bento_deployment.md) for specific instructions on 
how to deploy a production-ready Bento instance.
