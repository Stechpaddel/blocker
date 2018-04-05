#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
echo `date` start zone update >> /etc/blocker/blocker-log.txt
#delete the old zone file 

rm /etc/blocker/countries/all-zones.tar.gz
echo `date` remove old all zone file >> /etc/blocker/blocker-log.txt

#get the new zone files
wget -P /etc/blocker/countries/ http://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz
echo `date` get new zone file >> /etc/blocker/blocker-log.txt

#remove the old zones
rm /etc/blocker/countries/zones/*
echo `date` remove old zones >> /etc/blocker/blocker-log.txt

#unpack the zones
tar -xzf /etc/blocker/countries/all-zones.tar.gz -C /etc/blocker/countries/zones/
echo `date` unpack the all zone file >> /etc/blocker/blocker-log.txt

#start the worker for accrpt new ips from the countries
/etc/blocker/geoblock-worker.sh
echo `date` start the geoblock worker >> /etc/blocker/blocker-log.txt
