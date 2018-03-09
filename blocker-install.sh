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
tar -xzf /etc/blocker/contries/all-zones.tar.gz -C /etc/blocker/contries/zones/

#create the geoblock configfile
curl http://www.ipdeny.com/ipblocks/ 2>/dev/null |grep "<tr><td><p>" | sed 's/<tr><td><p>//' | sed 's/<table cellspacing=1 cellpadding1 border=1>//' | sed 's/<.*//' | sed 's/.$//' | cat >> /etc/blocker/geoblock.conf

#create config for port opening in geoip whitelistning
touch /etc/blocker/geoblock_open_ports.conf

#create whitelis ip list
touch /etc/blocker/whitelist.txt

mv ./blocker-worker.sh /etc/blocker/blocker-worker.sh
mv ./geoblock_helper.sh /etc/blocker/geoblock_helper.sh
mv ./geoblock_helper2.sh /etc/blocker/geoblock_helper2.sh
mv ./portscan_helper.sh /etc/blocker/portscan_helper.sh

