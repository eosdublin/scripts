!/bin/bash
################################################################################
#
# Script created by @samnoble for https://eosdublin.com
#
# Visit https://github.com/eosdublin/scripts for details.
#
################################################################################

# <Params>
PRODUCER=${1:-capycapybara}
# </Params>

# <Config>
TIMESTAMP="$(./cleos.sh get table eosio eosio producers -l 150 | grep $PRODUCER -A 8 | grep last_produced_block | cut -d':' -f2)"
# </Config>

# <Body>
if [ "$(uname)" == "Darwin" ]; then
    date -d "$((($TIMESTAMP * 500 + 946684800000) / 1000))"      
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    date --date "@$((($TIMESTAMP * 500 + 946684800000) / 1000))"
else
    echo "Unsupported system"
fi
# </Body>