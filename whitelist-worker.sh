#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#check if establibhed connections allow
s9="$(iptables -L -n | grep ESTABLISHED | awk '{print $2}')"
s10="RELATED,ESTABLISHED"

if [ "$s5" != "$s6" ];
then
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
echo `date` established connection accept rule not exist, added >> /etc/blocker/blocker-log.txt
fi

#check if the blocker-white chain exist, if no create them and passtrough ther traffic
s5="$(iptables -L -n | grep blocker-white | grep Chain | awk '{print $2}')"
s6="blocker-white"

if [ "$s5" != "$s6" ];
then
iptables -N blocker-white
iptables -t filter -A INPUT -j blocker-white
echo `date` blocker-geo chain and filter rule not exist, added  >> /etc/blocker/blocker-log.txt
fi

#flush the tables to remove old entrys
iptables -F blocker-white
echo  `date` flush blocker-white table >> /etc/blocker/blocker-log.txt
#set the ips als value and set them to allow, there are checked for dublicate
white_ips="$(cat /etc/blocker/whitelist.txt | awk '{print $1}')"
for var1 in $white_ips
do
dub_check="$(echo $var1)"
dub_comp="$(iptables -L blocker-white -n | grep $var1 | uniq | awk ' {print $4}')"
white_port="$(grep "$var1" /etc/blocker/whitelist.txt | awk '{ $1=""; ; print}')"

if [ "$dub_check" != "$dub_comp" ];
then

for var2 in $white_port
do
iptables -I blocker-white -s $var1 -p TCP --dport $var2 -j ACCEPT
done

fi

done

#check if return string to input chain exist, possibly create them
exist="$(iptables -L blocker-white -n | grep RETURN | awk '{print $1}' | sed '2,$d')"
comp="RETURN"

if [ "$exist" != "$comp" ]
then
iptables -A blocker-white -j RETURN
echo `date` blocker-white return rule not exist, added >> /etc/blocker/blocker-log.txt
fi

#check is iput default policy deny, and set them if no
s7="$(iptables -L -n | grep "Chain INPUT (policy ACCEPT)")"
s8="Chain INPUT (policy ACCEPT)"

if [ "$s7" == "$s8" ];
then
iptables -P INPUT DROP
echo `date` default input set to drop  >> /etc/blocker/blocker-log.txt
fi

