#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

##check if establibhed connections allow
s9="$(iptables -L -n | grep ESTABLISHED | awk '{print $2}')"
s10="RELATED,ESTABLISHED"

#check if the blocker-scan chain exist, if no create them and passtrough ther traffic
if [ "$s5" != "$s6" ];
then
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
fi

#check if the blocker-scan chain exist, if no create them and passtrough ther traffic
s3="$(iptables -L -n | grep blocker-scan | grep Chain | awk '{print $2}')"
s4="blocker-scan"

if [ "$s3" != "$s4" ];
then
iptables -N blocker-scan
iptables -t filter -A INPUT -j blocker-scan
fi

#grep the syslog to the tag "scanlog" rom the scanlogd and filter the ip where the scan came drom
#block the specific ip
bad_ips="$(grep -a "scanlog" /var/log/syslog | grep "port" |awk '{print $6 }' | sed 's/:.*//' | uniq)"

for var2 in $bad_ips
do
dub_check="$(echo $var2)"
dub_comp="$(iptables -L blocker-scan -n | grep $var2 | uniq | awk ' {print $4}')"

if [ "$dub_check" != "$dub_comp" ];
then
iptables -I blocker-scan -s $var2 -j DROP
fi

done

#check if return string to input chain exist, possibly create them
exist="$(iptables -L blocker-scan -n | grep RETURN | awk '{print $1}' | sed '2,$d')"
comp="RETURN"

if [ "$exist" != "$comp" ]
then
iptables -A blocker-scan -j RETURN
fi

#check is iput default policy deny, and set them if no
s7="$(iptables -L -n | grep "Chain INPUT (policy ACCEPT)")"
s8="Chain INPUT (policy ACCEPT)"

if [ "$s7" == "$s8" ];
then
iptables -P INPUT DROP
fi
