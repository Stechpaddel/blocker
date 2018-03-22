# blocker
An ufw compatible iptables wrapper for easy block IPs from other countrys and scanbots.

There are 2 dependencys:
curl - for the geoblock module
scanlogd - to detect the portscan

In blocker are 3 modules:
whitelist - for whitelistning known IPs, they dont are blocked
geoblock - set default policy to deny and allow access the ips from the selected countries
portscan - analyse the log edited from scanlogd to block the ips they are use portscans and not whitelisted 



Its at the moment under development and not working
