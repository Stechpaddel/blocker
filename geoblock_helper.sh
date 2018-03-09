#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

for var in "$@"
do
   # echo "$var"
unblock_ips="$(cat /etc/blocker/contries/zones/$var.zone)"
/etc/blocker/geoblock_helper2.sh $unblock_ips
#echo $unblock_ips
done
