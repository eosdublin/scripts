#!/bin/bash
################################################################################
#
# Script created by @samnoble for https://eosdublin.com
#
# Visit https://github.com/eosdublin/scripts for details.
#
################################################################################

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

# <Imports>
. $SCRIPT_PATH/../config.sh #$DATAROOT
# </Imports>

# <Parameters>
KEOSD_ARGS=$@
# </Parameters>

# <Configuration>
PID_FILE=$WALLET_DIR"/keosd.pid"
# </Configuration>

# <Body>
# Attempt to stop any running instance before starting a new one.
$SCRIPT_PATH/stop.sh $LOG_LEVEL || true
# Start keosd with our custom directory, passing in any additional arguments
$KEOSD --data-dir $WALLET_DIR --config-dir $WALLET_DIR $KEOSD_ARGS &> $WALLET_DIR/keosd_log.txt & echo $! > $PID_FILE
# Send notifications
$SCRIPT_PATH/../util/notify.sh $__INFO "$NODE_NAME keosd is up."
# </Body>

