

# VOLUME=$1 /dev/vdb
VOLUME=/dev/vdb
PROJECT=${2:-$HOSTNAME}
GO_VERSION=${3:-1.15.6}
SINGULARITY_VERSION=${4:-3.6.4}

# crate user and groups
useradd ${PROJECT}
useradd ${PROJECT}-data
usermod -a -G ${PROJECT}-data ${PROJECT}


# mount data folder and give the right acces
# We use xfs since it is easy to do an  xfs_growfs on the volume

mkdir /data/
mkfs.xfs ${VOLUME}
cat << _EOF_ >> /etc/fstab
$VOLUME                                 /data                    xfs     defaults        0 0
_EOF_
mount -a
chown  ${PROJECT}-data:${PROJECT}-data /data/

# install singularity

yum update -y &&      sudo yum groupinstall -y 'Development Tools' && yum install -y      openssl-devel      libuuid-devel      libseccomp-devel      wget      squashfs-tools      cryptsetup
OS=linux ARCH=amd64 &&     wget https://dl.google.com/go/go${GO_VERSION}.$OS-$ARCH.tar.gz &&     sudo tar -C /usr/local -xzvf go${GO_VERSION}.$OS-$ARCH.tar.gz &&     rm -f go${GO_VERSION}.$OS-$ARCH.tar.gz
wget https://github.com/sylabs/singularity/releases/download/v${SINGULARITY_VERSION}/singularity-${SINGULARITY_VERSION}.tar.gz &&     tar -xzf singularity-${SINGULARITY_VERSION}.tar.gz && cd singularity
PATH=${PATH}:/usr/local/go/bin/
./mconfig &&     make -C ./builddir &&   make -C ./builddir install
echo "source /usr/local/etc/bash_completion.d/singularity" > /etc/profile.d/singularity.sh

# add bento team ssh keys
cat << EOF >> /home/${PROJECT}/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDG2Un6lcY8cYVVhWguuduVMfi/C2vO0Uc3dVLXv4GRyoOyGP7JA60vJz6QC8QYBsL8cCg1lko05Lk1477yq1Mj5Wfg5E8iZ6T3MweHJ+ZLsRxOatxDO0GX3XTQk8Vd7HxYgclaRnSFwCJeL41euuMjTdapXUb0ycku6ipmGaxx2JupOE/KB8w8RjHxWX010FyR26NiPpALzCYzwALm+VaLZc+C6Io1LT1BNzr00hEVxMEyEjWQipaUTJKMdCxXtVNdnQieGtlGLw8U1uIarEHp/6eMt9/KEATX2CJhD8/hWJmKkfvaQUHNoU8c5z0mqNpraJAC6xWCdpbjUfE7O4c3 poq@moins
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlDucgrcjWRl3fEGLSoRl7a2izErUP/BNw9/+HSTfZUPaYhHgK06jPjp7fZAnudf5+fUl75xDvdBb3jiA7EUBM1TxZCreI/ZUCTtYFqNCedYo8zyB+RuuQznoJkqJIn8u67yDewftP5jz3MKGIe0ErxdisL/405AC23Bw2UcsRC/5RSe+X3aUQFwU4VSrDjVGMGJUB5xOEnrmIeRz8HE390T1zdzCfhrRF5puk4u4h7LeYp7Uorb5S5E0dx3DklSkYP65s6toGpZBUkO3W/J4w/g9n0XPhbkiY6PHi320SpYir8RHZnY+FB+IsD1TITJ0r6pIEWLWFxNDB7GFt0PXKQ== ksenia
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvIJZT7+JT230zFqHDVNDrxHk78U/JP64w7wm94+Z7/Ce+TNlbEH7W3lQ5DzdzIQfum1Zu4jnkhHgDV6V+dFrD1tb5AmzSErkA1r3PZSzj0w3FHU5Z43341BiAuw9EVX8Qa8SrufUwTzUyL3U0Uc7SxuxCO1WZa8LH3ISL/72gfoerJ+2JxC8KaEyg3JpVrzFn9FFz0y9K/JVk3ZCuKf+pDX1Bp0mpU8W5KG+YUv9dg3OsTF1brywlq5qyDjBy0A0OeVyCLj/EhCEwmeBW0S/q9pa7thTNaLtTdVptefHBBYEx3lXHCE6jpDT9y2AUCV9o7K2sXRdBiG9O2hRNmaxxnhIN8SlCN3qMeLhZ2wRrCJ4Q7hWIUZBoSBGgAO3aw6juRO3920XpK8nkYKaMXfFfeN5p8gy5epGsuY2IplhJ7tUBie7uFtdfIbikYX6XCCFE79rpMgGjTOF/imeIFxcyBii7IdQV4vDdKdgWO1va54QDz1y7sQ/uL2msz8AkC6k= brennan@Wolfsbane
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCh74kWmrjV8UUfwHf/dGcKQ7SVhVGYHRJR9ufKUPdnd1Fd4CmmDJxrjHSmhzS7+ZWiyz2Ho8b2GG9AT0BwK0hrZIr7pwDAOGfHjnbL8LHF8EyxCSv0r2FyxxW6YvjsNt0Dt2c42Ehe4t+RnGXX8Koj2GW8WCRHWIEViDNFDC0tuVlzfOr9IhYqdQhBSMusCh82oU5VxpqeeOuMgldfnyuyUuWoiDLExjjAmzMjFKFFs16pTuz3jt6AxZPFDD5ViUryVDqeOkjINHxGhKEwEu/y8wKucb5NXh+WNNQfdhNRSyBBG7kZv2SIrT4JOS7Uq72LDxsHkgRRo7GkC5iNN9VjYH1YiOemX4etUfEgHQiWH2eAFOABl1ZfTM6vHFTFtbAXtIgUOK7VkbmJxFpMCxun37dS1XIb990fXfli9A9pPSbGdBMAWNclOUKc/j+2ysVzboAhJeSYUW9u4gJT5v0uR/2zHQpCmYptWdUgO8UfjwLZoQRsmlhZBjXyuVUcNy9hQyvireA+ZvE6axwbhr0kS3M1ZSyh2tbaGtyu3txxlh0LdrPPP7Rg1d8E7C6NEwk7VNw/kBvGytcjbH0BRqBfurcbuZww9fwlCNNDVujUF0IB15MlUTSBuUPWzdmnC4BtTIcg+CKJ3ofy3JMpvUl4Sd408WmYd80idT8h2Et3iQ== Brownlee@heap
EOF
