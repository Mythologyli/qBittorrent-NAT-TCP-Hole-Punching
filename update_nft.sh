#!/bin/sh

#set -x

# Natter/NATMap
private_port=$4 # Natter: $3; NATMap: $4
public_port=$2 # Natter: $5; NATMap: $2

# qBittorrent.
qb_addr_url="http://localhost:8080" 
#qb_ip_addr="192.168.1.2" # Only needed when qbit runs on a different host
qb_username="admin"
qb_password="adminadmin"

echo "Update qBittorrent listen port to $public_port..."

# Update qBittorrent listen port.
qb_cookie=$(curl -s -i --header "Referer: $qb_addr_url" --data "username=$qb_username&password=$qb_password" $qb_addr_url/api/v2/auth/login | grep -i set-cookie | cut -c13-48)
curl -X POST -b "$qb_cookie" -d 'json={"listen_port":"'$public_port'"}' "$qb_addr_url/api/v2/app/setPreferences"

echo "Update nftables..."

# Use nftables to forward traffic.
nft delete table qbit_redirect
nft add table inet qbit_redirect
nft 'add chain inet qbit_redirect prerouting { type nat hook prerouting priority -100; }' 

if [ "$qb_ip_addr" = "" ];then
    nft add rule inet qbit_redirect prerouting tcp dport $private_port redirect to :$public_port
    # redirect the udp
    nft add rule inet qbit_redirect prerouting udp dport $private_port redirect to :$public_port
    # set the rules allow allow tcp and udp into the public_port
    nft 'add chain inet qbit_redirect INPUT { type filter hook input priority 0; policy drop;}'
    nft add rule inet qbit_redirect INPUT tcp dport $public_port accept
    nft add rule inet qbit_redirect INPUT udp dport $public_port accept
else
    nft add rule inet qbit_redirect prerouting tcp dport $private_port dnat to $qb_ip_addr:$public_port
    # redirect the udp
    nft add rule inet qbit_redirect prerouting udp dport $private_port dnat to $qb_ip_addr:$public_port
fi

echo "Done."