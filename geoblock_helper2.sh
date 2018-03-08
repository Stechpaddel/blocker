#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

for var in "$@"
do
#echo $var >> /etc/blocker/unblock_countries_ips.txt 
iptables -I blocker -s $var -p TCP --dport 80 -j ACCEPT
done

exist="$(iptables -L blocker -n | grep RETURN | awk '{print $1}' | sed '2,$d')" 
comp="RETURN"

if [ "$exist" != "$comp" ] 
then
iptables -A blocker -j RETURN
fi
