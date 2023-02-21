#!/bin/sh

# Natter/NATMap
private_port=$4 # Natter: $3; NATMap: $4
public_port=$2 # Natter: $5; NATMap: $2

# qBittorrent.
qb_web_port="8080"
qb_username="admin"
qb_password="adminadmin"

echo "Update qBittorrent listen port to $public_port..."

# Update qBittorrent listen port.
qb_cookie=$(curl -s -i --header "Referer: http://localhost:$qb_web_port" --data "username=$qb_username&password=$qb_password" http://localhost:$qb_web_port/api/v2/auth/login | grep -i set-cookie | cut -c13-48)
curl -X POST -b "$qb_cookie" -d 'json={"listen_port":"'$public_port'"}' "http://localhost:$qb_web_port/api/v2/app/setPreferences"

echo "Update iptables..."

# Use iptables to forward traffic.
LINE=$(iptables -t nat -nvL --line-number | grep ${private_port} | head -n 1 -)
LINE_NUMBER=($LINE)
iptables -t nat -D PREROUTING $LINE_NUMBER
iptables -t nat -A PREROUTING -p tcp --dport $private_port -j REDIRECT --to-port $public_port

echo "Done."