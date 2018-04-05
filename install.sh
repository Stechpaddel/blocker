#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#installscript

#create directory
blocker_dir="/etc/blocker"
if [ ! -d  "$blocker_dir" ]
then
mkdir /etc/blocker
echo `date` blocker directory created >> /etc/blocker/blocker-log.txt
fi

#create subdirectory for the files to geoblock
blocker_sub_dir="/etc/blocker/countries"
if [ ! -d  "$blocker_sub_dir" ]
then
mkdir /etc/blocker/countries
echo `date` blocker subdirectory countries created >> /etc/blocker/blocker-log.txt
fi


#get the zonefiles 
#all_zones="/etc/blocker/countries/all-zones.tar.gz"
if [ ! -f  /etc/blocker/countries/all-zones.tar.gz ]
then
wget -P /etc/blocker/countries/ http://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz
echo `date` all zone file downloaded >> /etc/blocker/blocker-log.txt
fi


#create subdirectory for the unpacked zone files
blocker_sub_dir2="/etc/blocker/countries/zones"
if [ ! -d  "$blocker_sub_dir2" ]
then
mkdir /etc/blocker/countries/zones
echo `date` blocker saubdirectory country zones created >> /etc/blocker/blocker-log.txt
fi
#mkdir /etc/blocker/contries/zones

#unpack the zonefiles
tar -xzf /etc/blocker/countries/all-zones.tar.gz -C /etc/blocker/countries/zones/
echo `date` unpack all zones file >> /etc/blocker/blocker-log.txt

#create the geoblock configfile
curl http://www.ipdeny.com/ipblocks/ 2>/dev/null |grep "<tr><td><p>" | sed 's/<tr><td><p>//' | sed 's/<table cellspacing=1 cellpadding1 border=1>//' | sed 's/<.*//' | sed 's/.$//' | cat >> /etc/blocker/geoblock.conf
echo `date` create countrylist  >> /etc/blocker/blocker-log.txt

#create config for port opening in geoip whitelistning
touch /etc/blocker/geoblock_open_ports.conf
echo `date` create geoblock_open_ports.conf  >> /etc/blocker/blocker-log.txt

#create whitelis ip list
touch /etc/blocker/whitelist.txt
echo `date` create whitelist.txt >> /etc/blocker/blocker-log.txt

#copy the other scrips in the directory
cp ./blocker/geoblock-worker.sh /etc/blocker/geoblock-worker.sh
echo `date` copy geoblock-worker.sh  >> /etc/blocker/blocker-log.txt
cp ./blocker/scanblock-worker.sh /etc/blocker/scanblock-worker.sh
echo `date` copy scanblock-worker.sh  >> /etc/blocker/blocker-log.txt
cp ./blocker/whitelist-worker.sh /etc/blocker/whitelist-worker.sh
echo `date` copy whitelist-worker.sh >> /etc/blocker/blocker-log.txt

#create iptables chains

#allow established connections
s9="$(iptables -L INPUT -n | grep ESTABLISHED | awk '{print $7}' | uniq)"
s10="RELATED,ESTABLISHED"

if [ "$s9" != "$s10" ];
then
iptables -I INPUT 1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
echo `date` add established connection accept >> /etc/blocker/blocker-log.txt
fi

#create whitelist chain

s5="$(iptables -L -n | grep blocker-white | grep Chain | awk '{print $2}')"
s6="blocker-white"

if [ "$s5" != "$s6" ];
then
iptables -N blocker-white
echo `date` create blocker-white chain >> /etc/blocker/blocker-log.txt
fi


#create portscan block chain
s3="$(iptables -L -n | grep blocker-scan | grep Chain | awk '{print $2}')"
s4="blocker-scan"

if [ "$s3" != "$s4" ];
then
iptables -N blocker-scan
echo `date` create blocker-scan chain >> /etc/blocker/blocker-log.txt
fi

#create geoblock chain
s1="$(iptables -L -n | grep blocker-geo | grep Chain | awk '{print $2}')"
s2="blocker-geo"

if [ "$s1" != "$s2" ];
then
iptables -N blocker-geo
echo `date` create blocker-geo chain >> /etc/blocker/blocker-log.txt
fi


# check if forward to the chains exist and the fule back to input
filter_exist="$(iptables -L -n | grep 0.0.0.0/0 | grep blocker-white | awk '{print $1}')"
filter_comp="blocker-white"

if [ "$filter_exist" != "$filter_comp" ];
then
iptables -t filter -I INPUT 2 -j blocker-white
iptables -t filter -I INPUT 3 -j blocker-scan
iptables -t filter -I INPUT 4 -j blocker-geo
iptables -A blocker-white -j RETURN
iptables -A blocker-scan -j RETURN
iptables -A blocker-geo -j RETURN
echo `date` create filter and return rules >> /etc/blocker/blocker-log.txt
fi


cron_geo_exist="$(ls /etc/cron.monthly/ | grep blocker-geoip)"
cron_geo_comp="blocker-geoip"

if [ "$cron_geo_exist" != "$cron_geo_comp" ];
then
cp ./blocker/blocker-geoip /etc/cron.monthly/blocker-geoip
echo `date` setup geoblock database update>> /etc/blocker/blocker-log.txt
fi


#create logfile
echo `date` blocker installed >> /etc/blocker/blocker-log.txt
