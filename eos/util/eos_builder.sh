#!/bin/bash

################################################################################
#
# Script created by @samnoble for https://eosdublin.com
#
# Visit https://github.com/eosdublin/scripts for details.
#
################################################################################

# <ArgumentValidation>
if [ "$#" -lt 4 ]; then
    echo "Missing parameters. Usage:"
        echo "eos_builder.sh BRANCH_NAME EOS_VERSION IS_TAG DISTRO_NAME EXPECTED_VERSION"
        echo .
        echo "BRANCH_NAME - The name of the branch to checkout from the EOS-Mainnet repository"
        echo "EOS_VERSION - The EOS platform version number, e.g. 0.0.0. This will be used in the Git commit message"
        echo "IS_TAG - (0 | 1) 0 denotes the BRANCH_NAME points to a branch, otherwise a tag"
		echo "DISTRO_NAME - The Linux distribution and version used to create the build, e.g. Ubuntu_18_04_LTS"
        echo "EXPECTED_VERSION - [optional] can be used to verify that the built nodeos binary outputs an expected version. If not, the script will fail."
        echo "EXPECTED_COMMIT - [optional] can be used to verify that the HEAD commit is as expected, if not the script will fail."
        exit 1
fi
# </ArgumentValidation>

# <Parameters>
BRANCH_NAME=$1
EOS_VERSION=$2
IS_TAG=$3
DISTRO_NAME=$4
EXPECTED_VERSION=${5:-0}
EXPECTED_COMMIT=${6:-0}
# </Parameters>

# <Body>

# Checkout the desired branch and build it
if ! [ -d ~/eos-mainnet ]; then
	mkdir ~/eos-mainnet
	git clone https://github.com/EOS-Mainnet/eos.git ~/eos-mainnet
fi

cd ~/eos-mainnet

if [ `git branch --list $BRANCH_NAME` ]; then
	git checkout $BRANCH_NAME
else
	
	git checkout master
	git fetch --all --tags --prune
	
    if [ $IS_TAG -eq 1 ]; then
        git checkout tags/$BRANCH_NAME -b $BRANCH_NAME
    else
        git checkout -b $BRANCH_NAME origin/$BRANCH_NAME
    fi
fi

GIT_COMMIT=$(git rev-parse HEAD)

if [ $GIT_COMMIT != $EXPECTED_COMMIT ]; then
    echo "Unexpected HEAD commit version. Expecting $EXPECTED_COMMIT but received $GIT_COMMIT."
    exit 1
fi

git submodule update --init --recursive

./eosio_build.sh

# Grab the nodeos version
NODEOS_VERSION=$(~/eos-mainnet/build/programs/nodeos/nodeos -v)

# If we have an expected version, make sure it's correct. Fail if assertion fails
if [ ! $EXPECTED_VERSION -eq 0 ]; then
    if [ ! $NODEOS_VERSION == $EXPECTED_VERSION ]; then
        echo "Unexpected nodeos version. Expecting $EXPECTED_VERSION but received $NODEOS_VERSION"
        exit 1
    fi
	
	echo
	echo ">>> nodeos version validated"
	echo
fi

if ! [ -d ~/nodeos-template ]; then
    mkdir ~/nodeos-template
	git clone https://github.com/eosdublin/nodeos-template.git ~/nodeos-template
fi

cd ~/nodeos-template

git checkout master
git checkout -b eos-mainnet/$DISTRO_NAME/$BRANCH_NAME

mkdir bin

cp ~/eos-mainnet/build/programs/nodeos/nodeos ~/nodeos-template/bin/
cp ~/eos-mainnet/build/programs/keosd/keosd ~/nodeos-template/bin/
cp ~/eos-mainnet/build/programs/cleos/cleos ~/nodeos-template/bin/
cp ~/eos-mainnet/build/programs/eosio-abigen/eosio-abigen ~/nodeos-template/bin/
cp ~/eos-mainnet/build/programs/eosio-launcher/eosio-launcher ~/nodeos-template/bin/

git add .

git commit -m "eos-mainnet commit $GIT_COMMIT. nodeos -v ($NODEOS_VERSION)"
git push -u origin eos-mainnet/$DISTRO_NAME/$BRANCH_NAME

echo "███████╗ ██████╗ ███████╗    ██████╗ ██╗   ██╗██████╗ ██╗     ██╗███╗   ██╗"
echo "██╔════╝██╔═══██╗██╔════╝    ██╔══██╗██║   ██║██╔══██╗██║     ██║████╗  ██║"
echo "█████╗  ██║   ██║███████╗    ██║  ██║██║   ██║██████╔╝██║     ██║██╔██╗ ██║"
echo "██╔══╝  ██║   ██║╚════██║    ██║  ██║██║   ██║██╔══██╗██║     ██║██║╚██╗██║"
echo "███████╗╚██████╔╝███████║    ██████╔╝╚██████╔╝██████╔╝███████╗██║██║ ╚████║"
echo "╚══════╝ ╚═════╝ ╚══════╝    ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝"

# </Body>
