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
MESSAGE=$1
# </Parameters>

# <Body>
curl -X POST --data-urlencode "payload={ \"username\": \"$NODE_NAME\", \"text\": \"$MESSAGE\" }" $SLACK_WEBHOOK_URL
# </Body>