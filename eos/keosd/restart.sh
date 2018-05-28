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
LOG_LEVEL=${1:-$__INFO}                                                                
KEOSD_ARGS=$2                                                                          
# </Parameters>                                                                        
                                                                                       
# <Configuration>                                                                      
# </Configuration>                                                                     
                                                                                       
# <Body>                                                                               
# Attempt to stop any running instance before starting a new one.                      
$SCRIPT_PATH/stop.sh $LOG_LEVEL                                                        
# Start keosd with our custom directory, passing in any additional arguments           
$SCRIPT_PATH/start.sh $LOG_LEVEL "$KEOSD_ARGS"                                         
# </Body>                                                                              