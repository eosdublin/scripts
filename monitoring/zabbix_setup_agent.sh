#!/bin/bash
################################################################################
#
# Created by Sam Noble for eosdublinwow https://eosdublin.com
# Visit https://github.com/eosdublin/nodeos-config for details.
#
# This script will install and configure a Zabbix Agent
#
################################################################################

# <ArgumentValidation>
if [ "$#" -lt 1 ]; then
    echo "Missing parameters. Usage:"
        echo "zabbix_setup_agent.sh AGENT_HOST_NAME SERVER_ADDRESS"
        echo .
        echo "AGENT_HOST_NAME - The fully qualified name of the host, as set in the Zabbix server"
        echo "SERVER_ADDRESS - The address of the Zabbix server"
        exit 1
fi
# </ArgumentValidation>

# <Parameters>
AGENT_HOST_NAME=${1:-host.name}
SERVER_ADDRESS=${2:-0.0.0.0}
# </Parameters>

# <Variables>
REMOVE_DOWNLOAD=0
# <Variable>

# <Body>

# Check if the zabbix group exists
if ! [ $(getent group zabbix) ]; then
	sudo groupadd zabbix
fi

# Check if the zabbix user already exists
if ! [ `id -u zabbix 2>/dev/null || echo -1` -ge 0 ]; then
    sudo useradd -g zabbix zabbix
fi


if ! [ "$(systemctl list-units --full -all | grep -F 'zabbix-agent.service')" ]; then
	echo "## Installing Zabbix Agent..."
	cd ~/
	wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-2+bionic_all.deb
	sudo dpkg -i zabbix-release_4.0-2+bionic_all.deb
	sudo apt-get update

	sudo apt-get -y install zabbix-agent jq

	REMOVE_DOWNLOAD=1
fi

sudo service zabbix-agent stop

echo "## Deploying agent configuration..."

echo "
Server=$SERVER_ADDRESS
ServerActive=$SERVER_ADDRESS
Hostname=$AGENT_HOST_NAME

### Option: Server
#	List of comma delimited IP addresses (or hostnames) of Zabbix servers.
#	Incoming connections will be accepted only from the hosts listed here.
#	If IPv6 support is enabled then '127.0.0.1', '::127.0.0.1', '::ffff:127.0.0.1' are treated equally.
#
# Mandatory: no
# Default:
# Server=

### Option: ServerActive
#	List of comma delimited IP:port (or hostname:port) pairs of Zabbix servers for active checks.
#	If port is not specified, default port is used.
#	IPv6 addresses must be enclosed in square brackets if port for that host is specified.
#	If port is not specified, square brackets for IPv6 addresses are optional.
#	If this parameter is not specified, active checks are disabled.
#	Example: ServerActive=127.0.0.1:20051,zabbix.domain,[::1]:30051,::1,[12fc::1]
#
# Mandatory: no
# Default:
# ServerActive=

### Option: Hostname
#	Unique, case sensitive hostname.
#	Required for active checks and must match hostname as configured on the server.
#	Value is acquired from HostnameItem if undefined.
#
# Mandatory: no
# Default:
# Hostname=
" | sudo tee /etc/zabbix/zabbix_agentd.d/user.conf > /dev/null

echo '
# Parameters: response_field, server_ip
UserParameter=nodeos_info[*],curl -s http://$2:8888/v1/chain/get_info | jq -r ".$1"
UserParameter=cleos_info[*],/home/eos/bin/cleos -u http://$1:8888 $2 | jq -r ".$3"
UserParameter=telos_producer_info[*],/home/eos/bin/cleos -u http://$1:8888 system listproducers --limit 1 --lower $2 --json | jq -r ".rows[0].$3"
' | sudo tee /etc/zabbix/zabbix_agentd.d/userparameter_nodeos.conf > /dev/null

echo "## Starting Zabbix Agent..."

sudo service zabbix-agent restart

if [ $REMOVE_DOWNLOAD -eq 1 ]; then
	rm ~/zabbix-release_4.0-2+bionic_all.deb
fi

echo "## Done."
# </Body>