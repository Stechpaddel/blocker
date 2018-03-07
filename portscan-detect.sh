#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#grep fatal messages frpm authlog
bad_ips="$(grep "fatal" /var/log/auth.log | awk '{print $11 }')"
echo $bad_ips
