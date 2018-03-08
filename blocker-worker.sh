#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

s3="$(iptables -L -n | grep blocker-scan | awk '{print $2}')"
s4="blocker-scan"

if [ "$s3" != "$s4" ];
then
iptables -N blocker-scan
iptables -t filter -A INPUT -j blocker-scan
echo "chain created"
fi

#grep fatal messages frpm authlog
bad_ips="$(grep "fatal" /var/log/auth.log | awk '{print $11 }')"
#echo $bad_ips

/root/blocker/portscan_helper.sh $bad_ips


#create the chaon fpr the blocked ips
s1="$(iptables -L -n | grep blocker-geo | awk '{print $2}')"
s2="blocker-geo"

if [ "$s1" != "$s2" ];
then
iptables -N blocker-geo
iptables -t filter -A INPUT -j blocker-geo
echo "chain created"
fi

# exclude the countrys you will allow
unblock_countries="$(grep yes /etc/blocker/geoblock.conf | awk '{print $(NF-1)}' | sed 's/(//' | sed 's/)//' | tr '[:upper:]' '[:lower:]')"

#unblock_ips="$(cat /etc/blocker/contries/zones/$unblock_countries.zone)"

sh /root/blocker/geoblock_helper.sh $unblock_countries
