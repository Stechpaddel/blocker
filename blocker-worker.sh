#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

iptables -F blocker-white

s5="$(iptables -L -n | grep blocker-white | grep Chain | awk '{print $2}')"
s6="blocker-white"

if [ "$s5" != "$s6" ];
then
iptables -N blocker-white
iptables -t filter -A INPUT -j blocker-white
fi

white_ips="$(cat /etc/blocker/whitelist.txt)"
/etc/blocker/whitelist_helper.sh $white_ips



s3="$(iptables -L -n | grep blocker-scan | grep Chain | awk '{print $2}')"
s4="blocker-scan"

if [ "$s3" != "$s4" ];
then
iptables -N blocker-scan
iptables -t filter -A INPUT -j blocker-scan
fi

#grep fatal messages from authlog
bad_ips="$(grep -a "fatal" /var/log/auth.log | awk '{print $11 }' | uniq)"

/etc/blocker/portscan_helper.sh $bad_ips

iptables -F blocker-geo

#create the chaon fpr the blocked ips
s1="$(iptables -L -n | grep blocker-geo | grep Chain | awk '{print $2}')"
s2="blocker-geo"

if [ "$s1" != "$s2" ];
then
iptables -N blocker-geo
iptables -t filter -A INPUT -j blocker-geo
fi

# exclude the countrys you will allow
unblock_countries="$(grep yes /etc/blocker/geoblock.conf | awk '{print $(NF-1)}' | sed 's/(//' | sed 's/)//' | tr '[:upper:]' '[:lower:]')"

#unblock_ips="$(cat /etc/blocker/contries/zones/$unblock_countries.zone)"

/etc/blocker/geoblock_helper.sh $unblock_countries

s7="$(iptables -L -n | grep "Chain INPUT (policy ACCEPT)")"
s8="Chain INPUT (policy ACCEPT)"

if [ "$s7" == "$s8" ];
then
iptables -P INPUT DROP
fi

