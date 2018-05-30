#!/bin/bash
################################################################################
#
# Script created by @samnoble for https://eosdublin.com
#
# Visit https://github.com/eosdublin/scripts for details.
#
################################################################################

if [ "$(uname)" == "Darwin" ]; then
    date -d "$((($@ * 500 + 946684800000) / 1000))"      
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    date --date "@$((($@ * 500 + 946684800000) / 1000))"
else
    echo "Unsupported system"
fi