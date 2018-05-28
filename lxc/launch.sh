#!/bin/bash
################################################################################
#
# Script created by @samnoble
#
# Visit https://github.com/eosdublin/scripts for details.
#
################################################################################

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

# <Imports>
. utilities.sh
# </Imports>

# <Parameters>
NODEOS_LXC_TEMPLATE=$1
CONTAINER_NAME=$2
PUBLIC_PROXY_PORT=${3:--}
PROXY_CONTAINER_PORT=${4:--}
NIC=${5:-eth0}
# </Parameters>

# <Body>
echo ">>> Launching container $CONTAINER_NAME from image $NODEOS_LXC_TEMPLATE..."
lxc launch --verbose $NODEOS_LXC_TEMPLATE $CONTAINER_NAME

echo ">>> Pausing to let container start..."
wait_bar 0.5
echo .

CONTAINER_IP=$(lxc list | grep $CONTAINER_NAME | egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

if [ ! "$PUBLIC_PROXY_PORT" = "-" ]; then
	echo ">>> Configuring iptables routing..."
	HOST_IP=$(hostname -I | awk '{print $1}')
	sudo iptables -t nat -I PREROUTING -i $NIC -p TCP -d $HOST_IP --dport $PUBLIC_PROXY_PORT -j DNAT --to-destination $CONTAINER_IP:$PROXY_CONTAINER_PORT
	echo ">>> Done ($HOST_IP -> $CONTAINER_IP)"
fi

echo ">>> Container launched ($CONTAINER_IP) <<<"
# </Body>