#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#installscript

#create directory
blocker_dir="/etc/blocker"
if [ ! -d  "$blocker_dir" ]
then
mkdir /etc/blocker
fi

#create subdirectory for the files to geoblock
blocker_sub_dir="/etc/blocker/countries"
if [ ! -d  "$blocker_sub_dir" ]
then
mkdir /etc/blocker/countries
fi


#get the zonefiles 
#all_zones="/etc/blocker/countries/all-zones.tar.gz"
if [ ! -f  /etc/blocker/countries/all-zones.tar.gz ]
then
wget -P /etc/blocker/countries/ http://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz
fi


#create subdirectory for the unpacked zone files
blocker_sub_dir2="/etc/blocker/countries/zones"
if [ ! -d  "$blocker_sub_dir2" ]
then
mkdir /etc/blocker/countries/zones
fi
#mkdir /etc/blocker/contries/zones

#unpack the zonefiles
tar -xzf /etc/blocker/countries/all-zones.tar.gz -C /etc/blocker/countries/zones/

#create the geoblock configfile
curl http://www.ipdeny.com/ipblocks/ 2>/dev/null |grep "<tr><td><p>" | sed 's/<tr><td><p>//' | sed 's/<table cellspacing=1 cellpadding1 border=1>//' | sed 's/<.*//' | sed 's/.$//' | cat >> /etc/blocker/geoblock.conf

#create config for port opening in geoip whitelistning
touch /etc/blocker/geoblock_open_ports.conf

#create whitelis ip list
touch /etc/blocker/whitelist.txt

cp ./blocker/all_zones-update.sh /etc/blocker/all_zones-update.sh
cp ./blocker/geoblock-worker.sh /etc/blocker/geoblock-worker.sh
cp ./blocker/scanblock-worker.sh /etc/blocker/scanblock-worker.sh
cp ./blocker/whitelist-worker.sh /etc/blocker/whitelist-worker.sh

#create iptables chains

#allow established connections
s9="$(ptables -L -n | grep ESTABLISHED | awk '{print $7}' | uniq)"
s10="RELATED,ESTABLISHED"

if [ "$s9" != "$s10" ];
then
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
fi

#create whitelist chain

s5="$(iptables -L -n | grep blocker-white | grep Chain | awk '{print $2}')"
s6="blocker-white"

if [ "$s5" != "$s6" ];
then
iptables -N blocker-white
iptables -t filter -A INPUT -j blocker-white
fi


#create portscan block chain
s3="$(iptables -L -n | grep blocker-scan | grep Chain | awk '{print $2}')"
s4="blocker-scan"

if [ "$s3" != "$s4" ];
then
iptables -N blocker-scan
fi

#create geoblock chain
s1="$(iptables -L -n | grep blocker-geo | grep Chain | awk '{print $2}')"
s2="blocker-geo"

if [ "$s1" != "$s2" ];
then
iptables -N blocker-geo
fi


# check if forward to the chains exist
filter_exist="$(iptables -L -n | grep 0.0.0.0/0 | grep blocker-white | awk '{print $1}')"
filter_comp="blocker-white"

if [ "$filter_exist" != "$filter_comp" ];
then
iptables -t filter -I INPUT 1 -j blocker-white
iptables -t filter -I INPUT 2 -j blocker-scan
iptables -t filter -I INPUT 3 -j blocker-geo
fi

