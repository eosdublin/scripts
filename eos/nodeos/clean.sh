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
# </Parameters>

# <Configuration>
# </Configuration>

# <Body>
if [ -f $DATA_DIR"/nodeos.pid" ]; then
  rm $DATA_DIR/nodeos.pid
fi

if [ -d $DATA_DIR"/blocks" ]; then
  rm -rf $DATA_DIR/blocks
fi

if [ -d $DATA_DIR"/shared_mem" ]; then
  rm -rf $DATA_DIR/shared_mem
fi

# TODO - Restore a snapshot here
# </Body>

# <Notifications>
$SCRIPT_PATH/../util/notify.sh $__INFO "$NODE_NAME node cleaned."
# </Notifications>
