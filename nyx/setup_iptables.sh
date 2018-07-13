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
CONTAINER_NAME=${1:-nyx}
# </Parameters>

# <Body>
echo ">>> Configuring iptables routing..."

HOST_IP=$(hostname -I | awk '{print $1}')
CONTAINER_IP=$(lxc list | grep $CONTAINER_NAME | egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t nat -A PREROUTING -p TCP -i eth0 -d $HOST_IP --dport 80 -j DNAT --to-destination $CONTAINER_IP:80
sudo iptables -t nat -A PREROUTING -p TCP -i eth0 -d $HOST_IP --dport 443 -j DNAT --to-destination $CONTAINER_IP:443

sudo iptables -t nat -A POSTROUTING -s $CONTAINER_IP ! -d $CONTAINER_IP -m comment --comment "lxdbr0" -j MASQUERADE

sudo iptables -I INPUT -p tcp --syn -m multiport --dports 80 -m connlimit --connlimit-above 10 --connlimit-mask 24 -j DROP -m comment --comment WFW-ClassC-limit
sudo iptables -I INPUT -p tcp --syn -m multiport --dports 80 -m connlimit --connlimit-above 1000 --connlimit-mask 0 -j DROP -m comment --comment WFW-total-limit
sudo iptables -I INPUT -p tcp --syn -m multiport --dports 443 -m connlimit --connlimit-above 10 --connlimit-mask 24 -j DROP -m comment --comment WFW-ClassC-limit
sudo iptables -I INPUT -p tcp --syn -m multiport --dports 443 -m connlimit --connlimit-above 1000 --connlimit-mask 0 -j DROP -m comment --comment WFW-total-limit
# </Body>