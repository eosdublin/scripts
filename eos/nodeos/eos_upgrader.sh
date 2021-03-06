#!/bin/bash

################################################################################
#
# Script created by @samnoble for https://eosdublin.com
#
# Visit https://github.com/eosdublin/scripts for details.
#
################################################################################

# <ArgumentValidation>
if [ "$#" -lt 1 ]; then
    echo "Missing parameters. Usage:"
        echo "eos_upgrade.sh BRANCH_NAME"
        echo
        echo "BRANCH_NAME - The name of the branch to checkout from the EOS-Mainnet repository"
        echo "ARCHIVE_BLOCKS - [optional] A flag used to control whether a backup of the blocks log should be taken during the upgrade."
        exit 1
fi
# </ArgumentValidation>

# <Setup>
SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
# </Setup

# <Parameters>
BRANCH_NAME=$1
ARCHIVE_BLOCKS=${2-1}
# </Parameters>

# <Body>
# TODO - Check the nodeos-template dir actually exists. If not, create it.
cd  ~/nodeos-template/

git fetch
git checkout -b $BRANCH_NAME origin/$BRANCH_NAME

# TODO - Check monit is running
sudo systemctl stop monit

. $SELF_PATH/nodeos/stop.sh

cp ~/nodeos-template/bin/* /home/eos/bin

if [ $ARCHIVE_BLOCKS -eq 1 ]; then
    . $SELF_PATH/eos/nodeos/archive_blocks.sh
fi

sudo systemctl start monit
# </Body>

