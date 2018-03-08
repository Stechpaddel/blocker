#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

for var in "$@"
do
echo $var >> /etc/blocker/unblock_countries_ips.txt 
done
