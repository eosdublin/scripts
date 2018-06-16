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
ARCHIVE_STORAGE=${1:-"/var/www/data/blocks"}
ARCHIVE_TAG=${2:-"eosdublin"}
# </Parameters>

# <Configuration>
DATE=`date -d "now" +'%Y_%m_%d-%H_%M'`
# </Configuration>

echo "Archiving BlockChain $ARCHIVE_TAG [$DATE]"

tar -pcvzf $ARCHIVE_STORAGE/nodeos_log-$ARCHIVE_TAG-$DATE.tar.gz $DATA_DIR/nodeos_log.txt
tar -pcvzf $ARCHIVE_STORAGE/blocks-$ARCHIVE_TAG-$DATE.tar.gz $DATA_DIR/blocks
ln -sf $ARCHIVE_STORAGE/blocks-$ARCHIVE_TAG-$DATE.tar.gz $ARCHIVE_STORAGE/blocks.tar.gz
ln -sf $ARCHIVE_STORAGE/nodeos_log-$ARCHIVE_TAG-$DATE.tar.gz $ARCHIVE_STORAGE/nodeos_log.tar.gz
