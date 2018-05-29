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
SEVERITY=$1
SOURCE=$2
# </Parameters>

# <Body>
$SCRIPT_PATH/slack.sh "$MONIT_HOST.$MONIT_SERVICE:$MONIT_EVENT: $MESSAGE\n$MONIT_DESCRIPTION\nm:$MONIT_PROCESS_MEMORY | c:$MONIT_PROCESS_CPU_PERCENT"
# </Body>
