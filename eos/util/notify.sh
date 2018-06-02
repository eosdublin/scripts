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
. $SCRIPT_PATH/../config.sh
# </Imports>

# <Parameters>
LOG_LEVEL=$1
SEVERITY=$2
MESSAGE=$3
# </Parameters>

# <Configuration>
should_log=$(($SEVERITY - $LOG_LEVEL))
# </Configuration>

# <Body>
# Only notify if $SEVERITY <= $$LOG_LEVEL
if [ $should_log -lt 1 ]; then
	$SCRIPT_PATH/util/slack.sh "$MESSAGE"
fi
# </Body>
