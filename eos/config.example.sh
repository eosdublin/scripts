#!/bin/bash
################################################################################
#
# Script created by @samnoble for https://eosdublin.com
#
# Visit https://github.com/eosdublin/scripts for details.
#
################################################################################

# An identifier for the node which is included in notifications
NODE_NAME=eosdublin.mainnet.one

# A webhook for Slack notifications
SLACK_WEBHOOK_URL=

# The absolute path to the nodeos binary
NODEOS=/home/eos/bin/nodeos

# The absolute path to the keosd binary
KEOSD=/home/eos/bin/keosd

# The absolute path to the nodeos config directory
CONFIG_DIR=/home/eos/config

# The absolute path to the eos config directory
DATA_DIR=/home/eos/data

# The absolute path to the keosd config and data directory
WALLET_DIR=/home/eos/wallet

# >>> Here be dragons <<<
# Constants
__ERROR=0
__WARNING=1
__INFO=2
__TRACE=3