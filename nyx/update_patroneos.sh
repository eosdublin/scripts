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
CONTAINER_NAME=$1
TARGET_PATH=${2:-/opt/patroneos}
# </Parameters>

# <Body>

if ! [ -d ~/patroneos ]; then
	git clone https://github.com/eosdublin/patroneos-bin.git ~/patroneos
fi

cd ~/patroneos
git pull

lxc exec $CONTAINER_NAME -- sudo pkill patroneosd
lxc file push ~/patroneos/patroneosd $CONTAINER_NAME/$TARGET_PATH/
lxc exec $CONTAINER_NAME -- nohup /bin/bash -c "sudo /home/ubuntu/script.sh"
# </Body>