# Bento: SD4H deployment guide

Now that you can SSH on the server, we need to setup the Bento repository for deployment.

## Init the Bento project directory

```bash
# connect to the server
ssh bento@<floating-ip>

# move to the /data directory
cd /app

# clone the Bento repo
git clone https://github.com/bento-platform/bento.git

# cd to the bento directory and configure the Bento instance
cd bento

# Follow the Bento installation instructions
# create venv for bentoctl
# create local.env config file for PROD
```
The installation [instructions](https://github.com/bento-platform/bento/blob/main/docs/installation.md) for Bento are found in the repository's documentation.

For next steps, you must have a local.env file with the variable `BENTOV2_DOMAIN` set to a domain you control. In this example, we are using a project subdomain on top of `bento.sd4h.ca`.

```bash
BENTOV2_DOMAIN=<project-name>.bento.sd4h.ca
```

## Create the DNS records

In order to obtain SSL certificates, we must first create the DNS records that will be used by the new Bento node.

At most, a bento node will require a DNS record for the following domains:

| Bento local.env variable  | Domain                             | Record type | Content               | Condition                  |
|---------------------------|------------------------------------|-------------|-----------------------|----------------------------|
| BENTOV2_DOMAIN            | <project>.bento.sd4h.ca            | A           | <node's floating IP>  | Always                     |
| BENTOV2_PORTAL_DOMAIN     | portal.<project>.bento.sd4h.ca     | CNAME       | staging.bento.sd4h.ca | Always                     |
| BENTOV2_AUTH_DOMAIN       | auth.<project>.bento.sd4h.ca       | CNAME       | staging.bento.sd4h.ca | If using internal IDP only |
| BENTOV2_CBIOPORTAL_DOMAIN | cbioportal.<project>.bento.sd4h.ca | CNAME       | staging.bento.sd4h.ca | If using cbioportal only   |


In the Cloudflare DNS management page, the creation of the record for `staging.bento.sd4h.ca` would look like this:


![Cloudflare DNS 'A' record for Bento staging](./dns_A_record.png)

Make sure that the `Proxy status` option is set to `DNS only` for all records.

We create the `A` record first, so that we can then make the other `CNAME` records point to it.


![Cloudflare DNS 'CNAME' record for Bento staging](./dns_CNAME_record.png)

Once the records are registered with the DNS server, you should be able to ssh the node using the domain name instead of the IP.

```bash
ssh bento@<project>.bento.sd4h.ca
```

For the next step, make sure all the DNS records you need certificates for are registered.

## Create the initial SSL certificates

With DNS records in place, we can ssh back to the server and request SSL certificates for our domains.
Make sure that Bento's local.env file is configured to use the domains for the newly created records.

Use the convenience script provided by Bento to request the initial SSL certificates from LetsEncrypt:

```bash
# from /app/bento in the server
cd ./etc/scripts

# Run the convenience script
bash init_certs_only.sh
# BEGIN init_certs_only.sh

# Will attempt a dry-run first

# Stopping gateway...
# Creating certificates for domains: -d staging.bento.sd4h.ca -d portal.staging.bento.sd4h.ca

# How would you like to authenticate with the ACME CA?
# SELECT OPTION 1

# Enter your email adress if prompted
# Accept LetsEncrypt user terms if prompted

# If dry-run ok, create real certs

# Repeat for auth
# END init_certs_only.sh

# go back to Bento dir
cd /app/bento

# check that the certs were created and are owned by the 'bento' user

# Should contain dirs <project>.bento.sd4h.ca, portal.<project>.bento.sd4h.ca
ls -la certs/gateway/letsencrypt/live/

# Should contain dir auth.<project>.bento.sd4h.ca
ls -la certs/auth/letsencrypt/live/
```

After creating the certificates, make sure that the certificates relative paths variables in `local.env` 
are configured to point to the right paths.

```bash
# local.env
BENTOV2_GATEWAY_INTERNAL_FULLCHAIN_RELATIVE_PATH=/live/<project>.bento.sd4h.ca/fullchain.pem
BENTOV2_GATEWAY_INTERNAL_PRIVKEY_RELATIVE_PATH=/live/<project>.bento.sd4h.ca/privkey.pem
BENTOV2_GATEWAY_INTERNAL_PORTAL_FULLCHAIN_RELATIVE_PATH=/live/portal.<project>.bento.sd4h.ca/fullchain.pem
BENTOV2_GATEWAY_INTERNAL_PORTAL_PRIVKEY_RELATIVE_PATH=/live/portal.<project>.bento.sd4h.ca/privkey.pem
BENTOV2_AUTH_FULLCHAIN_RELATIVE_PATH=/live/auth.<project>.bento.sd4h.ca/fullchain.pem
BENTOV2_AUTH_PRIVKEY_RELATIVE_PATH=/live/auth.<project>.bento.sd4h.ca/privkey.pem
```


## Start Bento

At this point the configuration of `local.env` should be complete, we can now finalize the deployment and start Bento.

```bash
# in /app/bento

# Open bentoctl venv
source env/bin/activate

# Pull the Bento Docker images
./bentoctl.bash pull

# Initialize the data directories
./bentoctl.bash init-dirs

# Initialize the data Docker networks
./bentoctl.bash init-docker

# Start Bento!
./bentoctl.bash run
```

Wait a minute for all the containers to start, you can check the status of the containers with `docker ps -a`.
If a Bento container has an `exited` status, check its logs with `./bentoctl.bash logs <service-name>` and try to diagnose the issue.

When all containers are up, you can open a browser window and navigate to your brand new Bento node!

## Migrate data

If needed, data can be migrated from one instance to another with one command.
Assuming you are in a terminal that can ssh the target instance.

```bash
# Copies    /app/bento_data/15/            from    qa.bento.c3g.calculquebec.ca
# To        /app/bento_data/old_qa_copy    on      qa.bento.sd4h.ca

# Dry run -n
rsync -ahvn /app/bento_data/15 bento@qa.bento.sd4h.ca/app/bento_data/old_qa_copy

# Real deal
rsync -ahv /app/bento_data/15 bento@qa.bento.sd4h.ca/app/bento_data/old_qa_copy
```

## Migrate Keycloak data

A Keycloak instance database can be moved from an instance to another.
However, the original database must be prepared for the migration if the new instance uses different domains.

1. Login to the Keycloak admin page in a browser
2. Select the Bento realm
3. Select the "Clients" section
4. Select the Bento client
5. Add the required URIs for the new domains
6. Save the modifications

In the example below, the original URIs were only for `ichange.c3g.calculquebec.ca`.
Since we plan on migrating to `ichange.bento.sd4h.ca` and `staging.ichange.bento.sd4h.ca`, we need to add those as well.

Once this is done, the auth data directory can be migrated to an instance that will serve the new domains, provided the credentials stay the same.

After the Keycloak DB is migrated, login to the admin page and remove the unecessary URIs on all instances.

![Web client redirects/origins](./keycloak_uris.png)

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
