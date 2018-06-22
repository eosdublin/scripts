#!/bin/bash
################################################################################
#
# Script created by @samnoble
#
# Visit https://github.com/eosdublin/scripts for details.
# Based on HKEOS's Prometheus https://github.com/HKEOS
#
################################################################################

# <Parameters>
STORAGE_POOL_SIZE=${1:-20GB}
# </Parameters>

# <Body>
sudo apt-get update
sudo apt-get -y install lxd zfsutils-linux bridge-utils

cat <<EOL | lxd init --preseed
config:
cluster: null
networks:
- config:
    ipv4.address: auto
    ipv6.address: auto
  description: ""
  managed: false
  name: lxdbr0
  type: ""
storage_pools:
- config:
    size: $STORAGE_POOL_SIZE
  description: ""
  name: default
  driver: zfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
EOL
# </Body>