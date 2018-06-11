#!/bin/bash
################################################################################
#
# Script created by @samnoble
#
# Visit https://github.com/eosdublin/scripts for details.
# Based on HKEOS's Prometheus https://github.com/HKEOS
#
################################################################################

# <Parameters>
NODEOS_URL=$1
NODEOS_PORT=$2
CERT_FILE=$3
LXC_IMAGE_URL=${4:-https://transfer.sh/UOxlD/prometheus}
# </Parameters>

function wait_bar () {
  for i in {1..10}
  do
    printf '=%.0s' {1..$i}
    sleep $1s
  done
}

# <Body>
sudo apt-get update
sudo apt-get -y install lxd zfsutils-linux bridge-utils

cat <<EOF | lxd init --preseed
config:
cluster: null
networks:
- config:
    ipv4.address: auto
    ipv6.address: auto
  description: ""
  managed: false
  name: lxdbr0
  type: ""
storage_pools:
- config:
    size: 20GB
  description: ""
  name: default
  driver: zfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
EOF

echo ">>> Downloading image..."

mkdir ~/downloads
cd ~/downloads
wget $LXC_IMAGE_URL

echo ">>> Importing image..."

lxc image import prometheus --alias prometheus

echo ">>> Launching"

lxc launch prometheus prometheus

echo ">>> Pausing to let container start..."
wait_bar 0.5

# Push haproxy.cfg
lxc file push -rp haproxy.cfg nyx/etc/haproxy/haproxy.cfg
lxc file push -rp $CERT_FILE nyx/etc/ssl/$CERT_FILE

lxc exec cerberus -- su - ubuntu

# Configure patroneos
sudo sed -i 's/nodeos-http-server-ip/$NODEOS_URL/g' /opt/patroneos/config.json
sudo sed -i 's/nodeos-http-port/$NODEOS_PORT/g' /opt/patroneos/config.json

# Configure HAProxy
sudo sed -i 's/PATH_TO_SSL_CERT/$CERT_FILE/g' /etc/haproxy/haproxy.cfg
sudo service haproxy restart

cd ~
sudo ./script.sh

# Leave the container
exit

echo ">>> Configuring iptables routing..."
HOST_IP=$(hostname -I | awk '{print $1}')
CONTAINER_IP=$(lxc list | grep prometheus | egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

sudo iptables -F
sudo iptables -t nat -A PREROUTING -p TCP -i eth0 -d $HOST_IP --dport 80 -j DNAT --to-destination $CONTAINER_IP:80
sudo iptables -t nat -A PREROUTING -p TCP -i eth0 -d $HOST_IP --dport 443 -j DNAT --to-destination $CONTAINER_IP:443

sudo /sbin/iptables -I INPUT -p tcp --syn -m multiport --dports 80 -m connlimit --connlimit-above 10 --connlimit-mask 24 -j DROP -m comment --comment WFW-ClassC-limit
sudo /sbin/iptables -I INPUT -p tcp --syn -m multiport --dports 80 -m connlimit --connlimit-above 1000 --connlimit-mask 0 -j DROP -m comment --comment WFW-total-limit
# </Body>