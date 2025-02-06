# qBittorrent NAT TCP Hole Punching

[中文](./README.zh.md)

Use [Natter](https://github.com/MikeWang000000/Natter)/[NATMap](https://github.com/heiher/natmap) to perform TCP hole punching under **Full Cone NAT**, making [qBittorrent](https://www.qbittorrent.org/) for a public IPv4-like experience.

## Requirement

+ Full Cone NAT.

+ The device running the script is only under one layer of NAT. If you run the script on other devices on the subnet, you can enable DMZ on the router.

+ qBittorrent is installed on the device running the script. If this condition is not met, you can manually modify the iptables port forwarding part of the script.

## Usage

1. Download the `update.sh` script.

2. You can use [Natter](https://github.com/MikeWang000000/Natter) or [NATMap](https://github.com/heiher/natmap) as hole punching program. Take NATMap as an example, download the NATMap binary file and put it in the same directory as `update.sh`.

3. Edit `update.sh`:

    + private_port: Natter fills in $3/NATMap fills in $4
    + public_port: Natter fills in $5/NATMap fills in $2
    + qb_web_port: The port of qBittorrent web service, usually 8080
    + qb_username: username
    + qb_password: password

4. Take NATMap as an example, run `sudo ./natmap -s stunserver2024.stunprotocol.org -h bing.com -b 45678 -e ./update.sh`.

   Among them, `stunserver2024.stunprotocol.org` is the STUN server address, and `bing.com` is the public network HTTP server address, which is used to maintain the NAT mapping relationship and generally does not need to be modified. `45678` is any locally available port.

## Thanks

+ [Natter](https://github.com/MikeWang000000/Natter)
+ [NATMap](https://github.com/heiher/natmap)