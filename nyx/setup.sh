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
CONTAINER_NAME=${4:-nyx}
SOURCE_IMAGE_NAME=${5:-prometheus}
LXC_IMAGE_URL=${6:-https://transfer.sh/UOxlD/prometheus}
# </Parameters>

# <Locals>
CERT_FILE_NAME=$(basename $CERT_FILE)
# </Locals>

function wait_bar () {
  for i in {1..10}
  do
    printf '=%.0s' {1..$i}
    sleep $1s
  done
}

# <Body>

if [ $(lxc list | grep $CONTAINER_NAME -c) -eq 0 ]
then
	
	sudo apt-get update
	sudo apt-get -y install lxd zfsutils-linux bridge-utils

cat <<EOL | lxd init --preseed
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
EOL
	 
	if ! [ -f ~/downloads/$SOURCE_IMAGE_NAME ]
	then
		echo ">>> Downloading image..."

		mkdir ~/downloads
		
		wget -O ~/downloads/$SOURCE_IMAGE_NAME $SOURCE_IMAGE_NAME $LXC_IMAGE_URL
	fi

	echo ">>> Importing image..."
	lxc image import ~/downloads/$SOURCE_IMAGE_NAME --alias $SOURCE_IMAGE_NAME

	echo ">>> Launching"

	lxc launch $SOURCE_IMAGE_NAME $CONTAINER_NAME

	echo ">>> Pausing to let container start..."
	wait_bar 1
fi

echo ">>> Pushing configuration files..."
lxc file push -rp haproxy.cfg $CONTAINER_NAME/etc/haproxy/
lxc file push -rp $CERT_FILE $CONTAINER_NAME/etc/ssl/private

# Configure patroneos
lxc exec $CONTAINER_NAME -- /bin/bash -c "sudo sed -i 's#<nodeos-http-server-ip>#$NODEOS_URL#g' /opt/patroneos/config.json"
lxc exec $CONTAINER_NAME -- /bin/bash -c "sudo sed -i 's#<nodeos-http-port>#$NODEOS_PORT#g' /opt/patroneos/config.json"

# Configure HAProxy
lxc exec $CONTAINER_NAME -- /bin/bash -c "sudo sed -i 's#PATH_TO_SSL_CERT#/etc/ssl/private/$CERT_FILE_NAME#g' /etc/haproxy/haproxy.cfg"
lxc exec $CONTAINER_NAME -- sudo service haproxy restart

lxc exec $CONTAINER_NAME -- nohup /bin/bash -c "sudo /home/ubuntu/script.sh"

echo ">>> Configuring iptables routing..."
HOST_IP=$(hostname -I | awk '{print $1}')
CONTAINER_IP=$(lxc list | grep $CONTAINER_NAME | egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t nat -A PREROUTING -p TCP -i eth0 -d $HOST_IP --dport 80 -j DNAT --to-destination $CONTAINER_IP:80
sudo iptables -t nat -A PREROUTING -p TCP -i eth0 -d $HOST_IP --dport 443 -j DNAT --to-destination $CONTAINER_IP:443

# TODO - This might not exist so add it if required. Replace the IP with your container IP
#sudo iptables -t nat -A POSTROUTING -s 10.228.53.61/24 ! -d 10.228.53.0/24 -m comment --comment "generated for LXD network lxdbr0" -j MASQUERADE

sudo /sbin/iptables -I INPUT -p tcp --syn -m multiport --dports 80 -m connlimit --connlimit-above 10 --connlimit-mask 24 -j DROP -m comment --comment WFW-ClassC-limit
sudo /sbin/iptables -I INPUT -p tcp --syn -m multiport --dports 80 -m connlimit --connlimit-above 1000 --connlimit-mask 0 -j DROP -m comment --comment WFW-total-limit

# Restart LXD to ensure the correct iptables rules are added
sudo service lxd restart
# </Body>
