#!/bin/bash
################################################################################
#
# Script created by @samnoble for https://eosdublin.com
#
# Visit https://github.com/eosdublin/scripts for details.
#
################################################################################

# SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# <Imports>
# </Imports>

# <Parameters>
INSTALLATION_ROOT=$1
BRANCH=$2
ISTAG=${3:-0}
SYMBOL=${4:-"EOS"}
BUILD=${5:-0}
# </Parameters>

# <Configuration>
# </Configuration>

# <Body>
if [ ! -d $INSTALLATION_ROOT ]; then
    mkdir $INSTALLATION_ROOT
fi

git clone https://github.com/EOSIO/eos.git $INSTALLATION_ROOT/eos

cd $INSTALLATION_ROOT/eos

if [ $ISTAG -eq 1 ]
then
    git fetch --all --tags --prune
    git checkout tags/$BRANCH -b $BRANCH
else
    git checkout $BRANCH -b $BRANCH
fi

git submodule update --init --recursive

# Update the symbol name
sed -i.bak "16i set( CORE_SYMBOL_NAME \"$SYMBOL\" )" CMakeLists.txt

# Do the build
if [ $BUILD -eq 1 ]
then
    . $INSTALLATION_ROOT/eos/eosio_build.sh
fi
# </Body>

