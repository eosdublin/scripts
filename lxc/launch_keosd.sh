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
EOS_CONFIG=$4
# </Parameters>

# <Body>

WALLET_PORT=$(grep http-server-address= $WALLET_CONFIG | cut -d':' -f2)

echo ">>> Launching container..."

if ! . launch.sh $NODEOS_LXC_TEMPLATE $CONTAINER_NAME $WALLET_PORT $WALLET_PORT
then
	echo ">>> Error launching wallet container."
	exit 1
fi

echo ">>> Pushing wallet config.ini..."

if ! lxc file push -rp "$WALLET_CONFIG" $CONTAINER_NAME/home/eos/config/
then
	echo ">>> Error pushing wallet configuration."
	exit 1
fi

echo ">>> Pushing EOS scripting config..."

if ! lxc file push -rp "$EOS_CONFIG" $CONTAINER_NAME/home/eos/scripts/eos
then
	echo ">>> Error pushing EOS scripting configuration."
	exit 1
fi

# Enable keosd in monit
lxc exec $CONTAINER_NAME -- sudo ln -s /etc/monit/conf-available/keosd /etc/monit/conf-enabled/ && sudo systemctl reload monit

echo ">>> Done creating wallet container. <<<"
# </Body>
