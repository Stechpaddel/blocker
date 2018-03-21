#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

s9="$(iptables -L -n | grep ESTABLISHED | awk '{print $2}')"
s10="RELATED,ESTABLISHED"

if [ "$s5" != "$s6" ];
then
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
fi

s5="$(iptables -L -n | grep blocker-white | grep Chain | awk '{print $2}')"
s6="blocker-white"

if [ "$s5" != "$s6" ];
then
iptables -N blocker-white
iptables -t filter -A INPUT -j blocker-white
fi

iptables -F blocker-white

white_ips="$(cat /etc/blocker/whitelist.txt)"
for var1 in $white_ips
do
dub_check="$(echo $var1)"
dub_comp="$(iptables -L blocker-white -n | grep $var1 | uniq | awk ' {print $4}')"

if [ "$dub_check" != "$dub_comp" ];
then
iptables -I blocker-white -s $var1 -p TCP -j ACCEPT
fi

done

exist="$(iptables -L blocker-white -n | grep RETURN | awk '{print $1}' | sed '2,$d')"
comp="RETURN"

if [ "$exist" != "$comp" ]
then
iptables -A blocker-white -j RETURN
fi


s7="$(iptables -L -n | grep "Chain INPUT (policy ACCEPT)")"
s8="Chain INPUT (policy ACCEPT)"

if [ "$s7" == "$s8" ];
then
iptables -P INPUT DROP
fi

