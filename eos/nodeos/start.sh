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
NODEOS_ARGS=$@
# </Parameters>

# <Configuration>
PID_FILE=$DATA_DIR"/nodeos.pid"
# </Configuration>

# <Body>
# Attempt to stop any running instance before starting a new one.
$SCRIPT_PATH/stop.sh || true
# Start nodeos with our custom directory, passing in any additional arguments
# TODO: Allow log file names to be configurable
# echo "Executing nodeos -- data-ri $DATA_DIR  --config-dir $CONFIG_DIR $NODEOS_ARGS &> $DATA_DIR/nodeos_log.txt & echo $! > $DATA_DIR/nodeos.pid"
$NODEOS --data-dir $DATA_DIR --config-dir $CONFIG_DIR $NODEOS_ARGS &> $DATA_DIR/nodeos_log.txt & echo $! > $PID_FILE
# Send notifications
$SCRIPT_PATH/../util/notify.sh $__INFO "$NODE_NAME is up."
# </Body>
