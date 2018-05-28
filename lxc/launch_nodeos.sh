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
EOS_LXC_TEMPLATE=$1
CONTAINER_NAME=$2
EOS_CONFIG=$3
SHELL_CONFIG=$4
# </Parameters>

# <Locals>
CONFIG_INI_NAME=$(basename $EOS_CONFIG)
SHELL_CONFIG_NAME=$(basename $SHELL_CONFIG)
# </Locals>

# <Body>

NODEOS_PORT=$(grep p2p-server-address= $EOS_CONFIG | cut -d':' -f2)

echo ">>> Launching nodeos container..."

if ! . launch.sh $EOS_LXC_TEMPLATE $CONTAINER_NAME $NODEOS_PORT $NODEOS_PORT
then
	echo ">>> Error launching nodeos container."
	exit 1
fi

echo ">>> Pushing nodeos config.ini..."

if ! lxc file push -rp "$EOS_CONFIG" $CONTAINER_NAME/home/eos/config/
then
	echo ">>> Error pushing nodeos configuration."
	exit 1
fi

if ! [ "$CONFIG_INI_NAME" = "config.ini" ]
then
    if ! lxc exec $CONTAINER_NAME -- mv /home/eos/config/$CONFIG_INI_NAME /home/eos/config/config.ini
    then
        echo ">>> Failed to rename $CONFIG_INI_NAME to config.ini"
        exit 1
    fi
fi

echo ">>> Pushing EOS scripting config..."

if ! lxc file push -rp "$SHELL_CONFIG" $CONTAINER_NAME/home/eos/scripts/eos
then
	echo ">>> Error pushing EOS scripting configuration."
	exit 1
fi

if ! [ "$SHELL_CONFIG_NAME" = "config.sh" ]
then
    if ! lxc exec $CONTAINER_NAME -- mv /home/eos/scripts/eos/$SHELL_CONFIG_NAME /home/eos/scripts/eos/config.sh
    then
        echo ">>> Failed to rename $SHELL_CONFIG_NAME to config.sh"
        exit 1
    fi
fi

# Enable keosd in monit
lxc exec $CONTAINER_NAME -- sudo ln -s /etc/monit/conf-available/nodeos /etc/monit/conf-enabled/ && sudo systemctl reload monit

echo ">>> Done creating nodeos container. <<<"
# </Body>
