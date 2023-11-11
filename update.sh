#!/bin/sh

# Natter/NATMap
private_port=$4 # Natter: $3; NATMap: $4
public_port=$2 # Natter: $5; NATMap: $2

# qBittorrent.
qb_web_host="192.168.50.3"
qb_web_port="8080"
qb_username="admin"
qb_password="adminadmin"

echo "Update qBittorrent listen port to $public_port..."

# Update qBittorrent listen port.
qb_cookie=$(curl -s -i --header "Referer: http://$qb_web_host:$qb_web_port" --data "username=$qb_username&password=$qb_password" http://$qb_web_host:$qb_web_port/api/v2/auth/login | grep -i set-cookie | cut -c13-48)
curl -X POST -b "$qb_cookie" -d 'json={"listen_port":"'$public_port'"}' "http://$qb_web_host:$qb_web_port/api/v2/app/setPreferences"

echo "Update iptables..."

# Use iptables to forward traffic.
LINE_NUMBER=$(iptables -t nat -nvL --line-number | grep ${private_port} | head -n 1 | awk '{print $1}')
if [ "${LINE_NUMBER}" != "" ]; then
    iptables -t nat -D PREROUTING $LINE_NUMBER
fi
iptables -t nat -I PREROUTING -p tcp --dport $private_port -j DNAT --to-destination $qb_web_host:$public_port

echo "Done."