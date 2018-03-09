#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#delete the old zone file and get an new 

rm /etc/blocker/countries/all-zones.tar.gz
wget -P /etc/blocker/countries/ http://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz

#unpack the zonefiles
tar -xzf /etc/blocker/countries/all-zones.tar.gz -C /etc/blocker/countries/zones/

#start the worker for accrpt new ips from the countries
/etc/blocker/blocker-worker.sh
