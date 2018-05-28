# Introduction
A repository for storing scripts used to manage and maintain our infrastructure.

## eos

Scripts that relate to the EOS platform to facilitate interactions with EOS programs such as nodeos.

### config.example.sh

This file defines a default set of configuration values which should be used to create your own *config.sh* file.

The file is used to store configuration values which describes your environment. Generally, only NODE_NAME need change between deployments.

### nodeos

These scripts relate to interactions with the EOS nodeos binary

#### clean.sh

Parameters:
- LOGLEVEL : int

Description: Cleans out the data directory in preparation for a new start. The file will remove the *blocks* and *shared_mem* folders.

*TODO* Update this script to remove the new 'state' directory


#### init.sh

Parameters:
- LOG_LEVEL: int
- NODEOS_ARGS: string
-- Arguments to pass on to nodeos

Description: Runs *nodeos* with the *--delete-all-blocks* and *--genesis-json* arguments, used to join a network.

#### restart.sh

Parameters:
- LOG_LEVEL: int
- NODEOS_ARGS: string
-- Arguments to pass on to nodeos

Description: Calls *stop.sh* followed by *start.sh*, forwarding *NODEOS_ARGS*.

#### start.sh

Parameters:
- LOG_LEVEL: int
- NODEOS_ARGS: string
-- Arguments to pass on to nodeos

Description: Starts nodeos forwarding *NODEOS_ARGS*. Values for --data-dir and --config-dir are taken from *config.sh*. Note, the script will call *stop.sh* before attempting to run *nodeos*.

A 'node started' notification is raised.

#### stop.sh

Parameters:
- LOG_LEVEL: int

Description: Uses the pid file created by *start.sh* to kill the *nodeos* process. A 'node stopped' notification is raised.
  
