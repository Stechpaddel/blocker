#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin


s9="$(iptables -L -n | grep ESTABLISHED | awk '{print $2}')"
s10="RELATED,ESTABLISHED"

if [ "$s5" != "$s6" ];
then
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
fi

s1="$(iptables -L -n | grep blocker-geo | grep Chain | awk '{print $2}')"
s2="blocker-geo"

if [ "$s1" != "$s2" ];
then
iptables -N blocker-geo
iptables -t filter -A INPUT -j blocker-geo
fi

iptables -F blocker-geo

unblock_countries="$(grep yes /etc/blocker/geoblock.conf | awk '{print $(NF-1)}' | sed 's/(//' | sed 's/)//' | tr '[:upper:]' '[:lower:]')"

open_ports="$(cat /etc/blocker/geoblock_open_ports.conf)"

for var3 in $unblock_countries
do
unblock_ips="$(cat /etc/blocker/countries/zones/$var3.zone)"

for var4 in $unblock_ips
do

for var5 in $open_ports
do

iptables -I blocker-geo -s $var4 -p TCP --dport $var5 -j ACCEPT
done
done
done

exist="$(iptables -L blocker-geo -n | grep RETURN | awk '{print $1}' | sed '2,$d')"
comp="RETURN"

if [ "$exist" != "$comp" ]
then
iptables -A blocker-geo -j RETURN
fi

s7="$(iptables -L -n | grep "Chain INPUT (policy ACCEPT)")"
s8="Chain INPUT (policy ACCEPT)"

if [ "$s7" == "$s8" ];
then
iptables -P INPUT DROP
fi

