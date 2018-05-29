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
. $SCRIPT_PATH/../config.sh
# </Imports>

# <Parameters>
LOG_LEVEL=${1:-$__INFO}
# </Parameters>

# <Configuration>
PID_FILE=$DATA_DIR"/nodeos.pid"
# </Configuration>

# <Body>
if [ -f $PID_FILE ]; then
	
	pid=$(cat $PID_FILE)
	
	#NOTE - Assuming no permission errors here.
	if [ -d "/proc/$pid/fd" ]; then
		kill $pid ||:
	fi
	
	while true; do
		[ ! -d "/proc/$pid/fd" ] && break
		echo -ne "."
		sleep 1
	done

	rm -r $PID_FILE
	
	echo -ne "\rnodeos stopped. \n"
	
	$SCRIPT_PATH/../util/notify.sh $LOG_LEVEL $__INFO "$NODE_NAME node stopped"
fi
# </Body>
