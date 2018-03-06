#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# exclude the countrys you will allow
block_countries="$(grep -v yes /etc/blocker/geoblock.conf | awk '{print $(NF-0)}' | sed 's/(//' | sed 's/)//' | tr '[:upper:]' '[:lower:]')"

block_ips="$(cat /etc/blocker/contries/zones/$block_countries.zone)"

