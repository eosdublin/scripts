#!/bin/bash
################################################################################
#
# Script created by @samnoble for https://eosdublin.com
# Based on the work from https://github.com/CryptoLions/
#
# Visit https://github.com/eosdublin/scripts for details.
#
################################################################################

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

# <Imports>
. $SCRIPT_PATH/../config.sh #$DATAROOT
# </Imports>

# <Parameters>
NODE_URL=$1
WALLET_URL=$2
CLEOS_PARAMS=$3
# </Parameters>

# <Body>
$CLEOS -u $NODE_URL --wallet-url $WALLET_URL "$CLEOS_PARAMS"
# </Body>