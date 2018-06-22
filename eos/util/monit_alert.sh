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

# <Body>
MESSAGE="$MONIT_EVENT for $MONIT_SERVICE"

if [ ! "$MONIT_SERVICE" = "$MONIT_HOST" ]; then
    MESSAGE+=" on $MONIT_HOST"
fi

MESSAGE+="\n$MONIT_DESCRIPTION"

$SCRIPT_PATH/slack.sh "$MESSAGE"
# </Body>
