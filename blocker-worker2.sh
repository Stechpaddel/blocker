#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

s9="$(iptables -L -n | grep ESTABLISHED | awk '{print $2}')"
s10="RELATED,ESTABLISHED"

if [ "$s5" != "$s6" ];
then
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
fi


iptables -F blocker-white

s5="$(iptables -L -n | grep blocker-white | grep Chain | awk '{print $2}')"
s6="blocker-white"

if [ "$s5" != "$s6" ];
then
iptables -N blocker-white
iptables -t filter -A INPUT -j blocker-white
fi

white_ips="$(cat /etc/blocker/whitelist.txt)"
#/etc/blocker/whitelist_helper.sh $white_ips
for var1 in "$white_ips"
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

#grep fatal messages from authlog
bad_ips="$(grep -a "fatal" /var/log/auth.log | awk '{print $11 }' | uniq)"

#/etc/blocker/portscan_helper.sh $bad_ips

for var2 in "$bad_ips"
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


iptables -F blocker-geo

#create the chaon fpr the blocked ips
s1="$(iptables -L -n | grep blocker-geo | grep Chain | awk '{print $2}')"
s2="blocker-geo"

if [ "$s1" != "$s2" ];
then
iptables -N blocker-geo
iptables -t filter -A INPUT -j blocker-geo
fi

# exclude the countrys you will allow
unblock_countries="$(grep yes /etc/blocker/geoblock.conf | awk '{print $(NF-1)}' | sed 's/(//' | sed 's/)//' | tr '[:upper:]' '[:lower:]')"

#unblock_ips="$(cat /etc/blocker/contries/zones/$unblock_countries.zone)"

#/etc/blocker/geoblock_helper.sh $unblock_countries

for var3 in "$unblock_countries"
do
   # echo "$var"
unblock_ips="$(cat /etc/blocker/countries/zones/$var.zone)"
#/etc/blocker/geoblock_helper2.sh $unblock_ips

for var4 in "$@"
do
#echo $var >> /etc/blocker/unblock_countries_ips.txt
iptables -I blocker-geo -s $var4 -p TCP --dport 80 -j ACCEPT
iptables -I blocker-geo -s $var4 -p TCP --dport 443 -j ACCEPT
done

exist="$(iptables -L blocker-geo -n | grep RETURN | awk '{print $1}' | sed '2,$d')"
comp="RETURN"

if [ "$exist" != "$comp" ]
then
iptables -A blocker-geo -j RETURN
fi

#echo $unblock_ips
done


s7="$(iptables -L -n | grep "Chain INPUT (policy ACCEPT)")"
s8="Chain INPUT (policy ACCEPT)"

if [ "$s7" == "$s8" ];
then
#iptables -P INPUT DROP
fi
