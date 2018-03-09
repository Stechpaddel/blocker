#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin


for var in "$@"
do
dub_check="$(echo $var)"
dub_comp="$(iptables -L blocker-white -n | grep $var | uniq | awk ' {print $4}')"

if [ "$dub_check" != "$dub_comp" ];
then
iptables -I blocker-white -s $var -p TCP -j ACCEPT
fi

done

exist="$(iptables -L blocker-white -n | grep RETURN | awk '{print $1}' | sed '2,$d')" 
comp="RETURN"

if [ "$exist" != "$comp" ] 
then
iptables -A blocker-white -j RETURN
fi
