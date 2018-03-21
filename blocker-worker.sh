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

s3="$(iptables -L -n | grep blocker-scan | grep Chain | awk '{print $2}')"
s4="blocker-scan"

if [ "$s3" != "$s4" ];
then
iptables -N blocker-scan
iptables -t filter -A INPUT -j blocker-scan
fi

bad_ips="$(grep -a "fatal" /var/log/auth.log | awk '{print $11 }' | uniq)"

for var2 in $bad_ips
do
dub_check="$(echo $var2)"
dub_comp="$(iptables -L blocker-scan -n | grep $var2 | uniq | awk ' {print $4}')"

if [ "$dub_check" != "$dub_comp" ];
then
iptables -I blocker-scan -s $var2 -j DROP
fi

done

exist="$(iptables -L blocker-scan -n | grep RETURN | awk '{print $1}' | sed '2,$d')"
comp="RETURN"

if [ "$exist" != "$comp" ]
then
iptables -A blocker-scan -j RETURN
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

