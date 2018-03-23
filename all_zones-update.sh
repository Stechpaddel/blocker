#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#delete the old zone file 

rm /etc/blocker/countries/all-zones.tar.gz

#get the new zone files
wget -P /etc/blocker/countries/ http://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz

#remove the old zones
rm /etc/blocker/countries/zones/*

#unpack the zones
tar -xzf /etc/blocker/countries/all-zones.tar.gz -C /etc/blocker/countries/zones/

#start the worker for accrpt new ips from the countries
/etc/blocker/geoblock-worker.sh
