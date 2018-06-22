#!/bin/bash
################################################################################
#
# Script created by @samnoble for https://eosdublin.com
#
# Visit https://github.com/eosdublin/scripts for details.
#
################################################################################
#
# Usage
# ------------------------------------------------------------------------------
#
# Requirements:
#     Twilio Account
#
# This is a very simple script which checks the producers system table to see
# if a given producer is within the top 21. If so, the script checks for the
# existence of a file, used to indicate whether the producer the producer has
# recently been elected in to the top 21.
#
#   - If the file exists, no further action is taken.
#   - If the file does not exist, it is created and alerts are sent out.
#
# If the given producer name is not present in the top 21, the existence of
# the aforementioned file is checked. The presence of the file indicates the
# producer has been relegated from the top 21.
#
#  - If the file exists, it is deleted and an alert is triggered.
#  - If the file does not exist, no further action is taken.
#
# When alerts are sent out, the Twilio REST API is used to trigger either
# a phone call or an SMS, or both.
#
# Alerts
#
# * Producer has been elected to top 21
#    - Phone call
#    - SMS
# * Producer has been relegated from the top 21
#    - SMS
#
# Refer to the following links to read more about the Twilio REST API
#   - https://www.twilio.com/docs/sms/send-messages
#   - https://www.twilio.com/docs/voice/make-calls
################################################################################

MY_SID=<YOUR_TWILIO_SID>
MY_AUTH=<YOUR_TWILIO_AUTH_TOKEN>
MY_TO_NUMBER="<RECIPINT_PHONE_NUMBER>"
MY_FROM_NUMBER="<TWILIO_PHONE_NUMBER>"
MY_TWIML=<TWIML_URL_FOR_VOICE_CALL>

# <Constants>
CLEOS=~/nodeos-template/bin/cleos
CHECK_FILE=~/monitoring/is_top21
SILENT=0
INFO=1
DEBUG=2
TRACE=3
# </Constants>

# <Arguments>
PRODUCER_NAME=${1:-eosdublinwow}
SEND_ALERTS=${2:-0}
TWILIO_SID=${3:-$MY_SID}
TWILIO_AUTH=${4:-$MY_AUTH}
TO_NUMBER=${5:-$MY_TO_NUMBER}
FROM_NUMBER=${6:-$MY_FROM_NUMBER}
TWIML_URL=${7:-$MY_TWIML}
# </Arguments>

# <Body>
TOP21=$($CLEOS -u https://api2.eosdublin.io system listproducers -l 20)
IS_TOP21=$(echo $TOP21 | grep "$PRODUCER_NAME")

if [ -n "$IS_TOP21" ] && [ ! -f $CHECK_FILE ]; then

    echo "$PRODUCER_NAME was just elected in to the top 21"

    if [ $SEND_ALERTS -eq 1 ]; then
        curl -X POST https://api.twilio.com/2010-04-01/Accounts/$TWILIO_SID/Messages.json \
            --data-urlencode "Body=IN TOP 21 ALERT for $PRODUCER_NAME" \
            --data-urlencode "From=$FROM_NUMBER" \
            --data-urlencode "To=$TO_NUMBER" \
            -u $TWILIO_SID:$TWILIO_AUTH

        curl -X POST https://api.twilio.com/2010-04-01/Accounts/$TWILIO_SID/Calls.json \
            --data-urlencode "Url=$TWIML_URL" \
            --data-urlencode "To=$TO_NUMBER" \
            --data-urlencode "From=$FROM_NUMBER" \
            -u $TWILIO_SID:$TWILIO_AUTH
    fi

    touch $CHECK_FILE

elif [ -f $CHECK_FILE ]; then

    echo "$PRODUCER_NAME is out of the top 21"

    if [ $SEND_ALERTS -eq 1 ]; then
        # The producer was in the top 21, but no longer is. Just send an SMS here
        curl -X POST https://api.twilio.com/2010-04-01/Accounts/$TWILIO_SID/Messages.json \
        --data-urlencode "Body=OUT OF TOP 21 ALERT for $PRODUCER_NAME" \
        --data-urlencode "From=$FROM_NUMBER" \
        --data-urlencode "To=$TO_NUMBER" \
        -u $TWILIO_SID:$TWILIO_AUTH
    fi

    rm $CHECK_FILE
fi
# </Body>