# Adding a new project node to Bento


## update the openstack projet itself

### Add a new bento node  

We create the volume and attatch it to the new server.
All the node provisioning is done with cloud init file fed in the `--user-data` option
```
openstack volume create --size 1000 bqc19-data
openstack server create --flavor p2-3gb --image CentOS-7-x64-2020-03  --nic net-id=a5bee81b-1dc3-401b-8d81-0f48d5705d42 --security-group default  --security-group obentoyasan-secgroup  --boot-from-volume 10   --user-data bento_<BENTO PROJECT NAME>_node.yaml   --block-device-mapping vdb=<BENTO PROJECT NAME>-data  <BENTO PROJECT NAME>




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
