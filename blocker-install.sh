#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#installscript

#create directory
mkdir /etc/blocker

#create subdirectory for the files to geoblock
mkdir /etc/blocker/contries

#get the zonefiles 
wget -P /etc/blocker/contries/ http://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz

#create subdirectory for the unpacked zone files
mkdir /etc/blocker/contries/zones

#unpack the zonefiles
tar -xzf /etc/blocker/contries/all-zones.tar.gz -C /etc/blocker/contries/zones/

#create the geoblock configfile
curl http://www.ipdeny.com/ipblocks/ 2>/dev/null |grep "<tr><td><p>" | sed 's/<tr><td><p>//' | sed 's/<table cellspacing=1 cellpadding1 border=1>//' | sed 's/<.*//' | sed 's/.$//' | cat >> /etc/blocker/geoblock.conf
