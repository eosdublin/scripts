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

echo "Launching keosd..."
lxc exec $CONTAINER_NAME -- /home/eos/scripts/eos/keosd/start.sh

echo ">>> Done creating wallet container. <<<"
# </Body>
