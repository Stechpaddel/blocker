#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#create the chaon fpr the blocked ips
s1="$(iptables -L | grep blocker | awk '{print $2}')"
s2="blocker"

if [ "$s1" != "$s2" ];
then
iptables -N blocker
echo "chain created"
fi

# exclude the countrys you will allow
unblock_countries="$(grep yes /etc/blocker/geoblock.conf | awk '{print $(NF-1)}' | sed 's/(//' | sed 's/)//' | tr '[:upper:]' '[:lower:]')"

#unblock_ips="$(cat /etc/blocker/contries/zones/$unblock_countries.zone)"

sh /root/blocker/geoblock_helper.sh $unblock_countries

