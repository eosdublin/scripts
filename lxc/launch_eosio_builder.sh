#!/bin/bash
################################################################################
#
# Script created by @samnoble
#
# Visit https://github.com/eosdublin/cerberus for details.
#
################################################################################

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

# <Imports>
. utilities.sh
# </Imports>

# <Parameters>
EOS_BRANCH=${1:-master}
IS_TAG=${2:-0}
INSTALLATION_ROOT=${3:-"~"}
CONTAINER_NAME=${4:-$EOS_BRANCH}
# </Parameters>

# <Body>
echo ">>> Building EOS: branch $EOS_BRANCH, IsTag=$IS_TAG, to ROOT $INSTALLATION_ROOT in container $CONTAINER_NAME"

# Check to see if the container exists first
EXISTING_CONTAINER=$(lxc list --format csv -c n "$CONTAINER_NAME")
if [ "$EXISTING_CONTAINER" = "$CONTAINER_NAME" ] 
then
	echo "A container named $CONTAINER_NAME already exists. Please pick a new name or delete the container and try again."
	exit 1
fi

echo ">>> Launching container..."
if ! lxc launch --verbose ubuntu:18.04 $CONTAINER_NAME
then
	echo "Failed to create LXC container due to the above error."
	exit 1
fi

echo ">>> Pausing to let container start..."
wait_bar 0.5

printf "\\n>>> Container started. Pushing setup files...\\n"
if ! lxc file push -rp --verbose $SCRIPT_PATH/install_eos_version.sh $CONTAINER_NAME/tmp/
then
	echo "Failed to push setup files to container. See above error."
	exit 1
fi

echo ">>> Running EOS installer script..."
lxc exec $CONTAINER_NAME -- /bin/bash /tmp/install_eos_version.sh $INSTALLATION_ROOT $EOS_BRANCH $IS_TAG "EOS" 1

printf ">>> Setup Complete <<<"
# </Body>