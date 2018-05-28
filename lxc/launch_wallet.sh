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
WALLET_CONFIG=$3
# </Parameters>

# <Body>
if ! . launch.sh $NODEOS_LXC_TEMPLATE $CONTAINER_NAME
then
	echo ">>> Error launching wallet container."
	exit 1
fi

if ! lxc file push -rp "$WALLET_CONFIG" $CONTAINER_NAME/home/eos/config/
then
	echo ">>> Error pushing wallet configuration."
	exit 1
fi

CONTAINER_IP=$(lxc list | grep $CONTAINER_NAME | egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
WALLET_PORT=$(grep http-server-address= $WALLET_CONFIG | cut -d':' -f2)
HOST_IP=$(hostname -I | awk '{print $1}')

sudo iptables -t nat -I PREROUTING -i eth0 -p TCP -d $HOST_IP --dport $WALLET_PORT -j DNAT --to-destination $CONTAINER_IP:$WALLET_PORT

echo "Launching keosd..."
lxc exec $CONTAINER_NAME -- /home/eos/scripts/eos/keosd/start.sh

echo ">>> Done creating wallet container. <<<"
# </Body>
