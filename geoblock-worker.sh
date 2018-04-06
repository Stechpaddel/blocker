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

#allow localhost connections
localhost_check="$(iptables -nvL | grep "lo" | awk '{print $6}')"
localhost_comp="lo"

if [ "$localhost_check" != "$localhost_comp" ];
then
iptables -A INPUT -i lo -j ACCEPT
echo `date` add localhost connection accept >> /etc/blocker/blocker-log.txt
fi

#check if the blocker-geo chain exist, if no create them and passtrough ther traffic
s1="$(iptables -L -n | grep blocker-geo | grep Chain | awk '{print $2}')"
s2="blocker-geo"

if [ "$s1" != "$s2" ];
then
iptables -N blocker-geo
iptables -t filter -A INPUT -j blocker-geo
echo `date` blocker-geo chain and filter rule not exist, added  >> /etc/blocker/blocker-log.txt
fi

#flush the tables to remove old entrys
iptables -F blocker-geo
echo `date` flush blocker-geo table >> /etc/blocker/blocker-log.txt
#grep the unblocked coutries
#cat the coutries to reache the ip and subnet
#accept the ips over the definied ports in geoblock_open_ports.conf
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

#check if return string to input chain exist, possibly create them
exist="$(iptables -L blocker-geo -n | grep RETURN | awk '{print $1}' | sed '2,$d')"
comp="RETURN"

if [ "$exist" != "$comp" ]
then
iptables -A blocker-geo -j RETURN
echo `date` blocker-geo return rule not exist, added >> /etc/blocker/blocker-log.txt
fi

#check is iput default policy deny, and set them if no
s7="$(iptables -L -n | grep "Chain INPUT (policy ACCEPT)")"
s8="Chain INPUT (policy ACCEPT)"

if [ "$s7" == "$s8" ];
then
iptables -P INPUT DROP
echo `date` default input set to drop >> /etc/blocker/blocker-log.txt
fi

