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
git clone https://github.com/eosdublin/patroneos-bin.git ~/patroneos
lxc file push ~/patroneos/patroneosd $CONTAINER_NAME
# </Body>