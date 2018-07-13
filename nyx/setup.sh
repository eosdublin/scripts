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


echo ">>> Installing monit in the container..."
lxc exec $CONTAINER_NAME -- /bin/bash -c "sudo apt-get update & sudo apt-get install -y monit"

echo ">>> Pushing configuration files..."
lxc file push -rp haproxy.cfg $CONTAINER_NAME/etc/haproxy/
lxc file push -rp $CERT_FILE $CONTAINER_NAME/etc/ssl/private
lxc file push ../monit/patroneos $CONTAINER_NAME/etc/monit/conf-available
lxc file push start_patroneos.sh $CONTAINER_NAME/home/ubuntu

lxc exec $CONTAINER_NAME -- /bin/bash -c "sudo ln -s /etc/monit/conf-available/patroneos /etc/monit/conf-enabled/patroneos"

# Configure patroneos
lxc exec $CONTAINER_NAME -- /bin/bash -c "sudo sed -i 's#<nodeos-http-server-ip>#$NODEOS_URL#g' /opt/patroneos/config.json"
lxc exec $CONTAINER_NAME -- /bin/bash -c "sudo sed -i 's#<nodeos-http-port>#$NODEOS_PORT#g' /opt/patroneos/config.json"

# Configure HAProxy
lxc exec $CONTAINER_NAME -- /bin/bash -c "sudo sed -i 's#PATH_TO_SSL_CERT#/etc/ssl/private/$CERT_FILE_NAME#g' /etc/haproxy/haproxy.cfg"
lxc exec $CONTAINER_NAME -- sudo service haproxy restart

lxc exec $CONTAINER_NAME -- nohup /bin/bash -c "sudo /home/ubuntu/script.sh"

# Add iptables rules
./setup_iptables.sh $CONTAINER_NAME

# Add files so we can run iptables setup after a reboot
sudo cp setup_iptables.sh /usr/local/bin/setup_iptables.sh
sudo chown root:root /usr/local/bin/setup_iptables.sh
sudo cp cron/set_iptables_rules /etc/cron.d
sudo chown root:root /etc/cron.d/set_iptables_rules

# Restart LXD to ensure the correct iptables rules are added
sudo service lxd restart
# </Body>
