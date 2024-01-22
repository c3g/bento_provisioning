# Adding a new project node to Bento


## update the openstack projet itself

### Add a new bento node

The `bento_openstack_cli.sh` script can be used to quickly create a new Bento node.
It uses the `openstack` cli to create the server (VM) with required volumes and network interfaces.
The `cloud-config` file `template_bento.yaml` is used to setup the users, authorised SSH keys, and mounts.

Usage example:

```bash
# Load the OpenStack RC env variables
source Bento-openrc.sh

# Lauch the node creation script with a config argument
bash bento_openstack_cli.sh configs/config_template.sh

# The script will ask to validate the project's name from the config

# If all went well, you should see the new instance
openstack server list

# If your ssh key is listed in template_bento.yaml and the server has a floating IP, you can ssh with:
ssh bento@<floating-ip>
```


### update the security group

Add the new ssh port to the obentoyasan-secgroup security group:
```
openstack security group rule create obentoyasan-secgroup   --protocol tcp --dst-port 2222:222<N+1> --ingress --remote-ip 0.0.0.0/0
```
list and remove the old 2222:222<N> rule :
```openstack security group rule list

openstack security group rule delete <ID>
```


## On the proxy server

Setup the stream.conf_tpl file to <project>.conf and copy it to
`/etc/nginx/stream.d folder`

Do the same thing for the https setup
```
cat nginx_config.conf_tpl  | sed 's/<project>/bcq19/'  > bcq19.conf_tpl
```
to be copied to
`/etc/nginx/conf.d`


add the new node ip in the `/etc/host` file. Open the new ssh port to selinux

```
semanage port -a -t http_port_t -p tcp 2224
```

add the new letsencrypt adress


```
certbot certonly  --nginx  -w /usr/share/nginx/html -d bqc19.c3g.calculquebec.ca
```

restart nginx


```
systemctl restart nginx
```
