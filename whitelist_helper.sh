#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

for var in "$@"
do
iptables -I blocker-white -s $var -p TCP -j ACCEPT
done

exist="$(iptables -L blocker-white -n | grep RETURN | awk '{print $1}' | sed '2,$d')" 
comp="RETURN"

if [ "$exist" != "$comp" ] 
then
iptables -A blocker-white -j RETURN
fi
