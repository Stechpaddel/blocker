#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

for var in "$@"
do
#echo $var >> /etc/blocker/unblock_countries_ips.txt 
iptables -I blocker-geo -s $var -p TCP --dport 80 -j ACCEPT
iptables -I blocker-geo -s $var -p TCP --dport 443 -j ACCEPT
done

exist="$(iptables -L blocker-geo -n | grep RETURN | awk '{print $1}' | sed '2,$d')" 
comp="RETURN"

if [ "$exist" != "$comp" ] 
then
iptables -A blocker-geo -j RETURN
fi
