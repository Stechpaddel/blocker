#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

for var in "$@"
do
iptables -I blocker-scan -s $var -j DROP 
done



exist="$(iptables -L blocker-scan -n | grep RETURN | awk '{print $1}' | sed '2,$d')" 
comp="RETURN"

if [ "$exist" != "$comp" ] 
then
iptables -A blocker-scan -j RETURN
fi
