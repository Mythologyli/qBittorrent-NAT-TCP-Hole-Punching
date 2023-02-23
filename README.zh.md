# qBittorrent NAT TCP 打洞

详细说明请前往[我的博客](https://myth.cx/p/qbittorrent-nat-tcp-hole-punching/)。

利用 [Natter](https://github.com/MikeWang000000/Natter)/[NATMap](https://github.com/heiher/natmap) 在 **Full Cone NAT** 下进行 TCP 打洞，从而使 [qBittorrent](https://www.qbittorrent.org/) 获得近似于公网 IPv4 的体验。

## 使用条件

+ 网络运营商 NAT 为 Full Cone NAT，又称 NAT1。

+ 运行脚本的设备只处于一层 NAT 下（网络运营商 NAT）。你可以将光猫设置为桥接模式，在路由器上运行脚本。如果你在子网的其他设备上运行脚本，你可以在路由器上开启 DMZ 功能。

+ qBittorrent 安装在运行脚本的设备上。如果不满足此条件，你可以手动修改脚本中 iptables 端口转发的部分。

## 使用方法

1. 下载 `update.sh` 脚本。

2. 你可以使用 [Natter](https://github.com/MikeWang000000/Natter) 或 [NATMap](https://github.com/heiher/natmap) 作为打洞程序。以 NATMap 为例，下载 NATMap 二进制文件，放在 `update.sh` 同一目录下。

3. 编辑 `update.sh`：

   + private_port: Natter 填写 $3/NATMap 填写 $4
   + public_port: Natter 填写 $5/NATMap 填写 $2
   + qb_web_port: qBittorrent Web 服务的端口，一般为 8080
   + qb_username: 用户名
   + qb_password: 密码

4. 以 NATMap 为例，运行 `sudo ./natmap -s stun.stunprotocol.org -h baidu.com -b 45678 -e ./update.sh` 即可。

   其中，`stun.stunprotocol.org` 为 STUN 服务器地址，`baidu.com` 为公网 HTTP 服务器地址，用于维持 NAT 映射关系，一般不用修改。`45678` 为任意本地可用端口。

## 原理

在 Full Cone NAT 即完全锥形 NAT 环境下，同一内部 IP 地址和端口发送的所有请求，都被映射到某个特定的外部 IP 地址和端口。并且，**任何**外部主机通过向映射的外部 IP 地址和端口发送报文，都可以实现和内部主机进行通信。因此，如果能不断维持一组映射关系，即可实现在某个外部 IP 地址和端口上监听的效果。

我们可以利用 [Natter](https://github.com/MikeWang000000/Natter) 或 [NATMap](https://github.com/heiher/natmap) 维持 NAT 映射关系，并得到内部端口对应的外部 IP 地址和端口。这样，如果我们将这个内部端口收到的数据转发到 qBittorrent 正在监听的端口，就可以接收到公网 IPv4 下的其他 Peer 的入站请求。

还有一个问题没有解决：我们应该如何告知 Tracker 我们的公网 IPv4 地址和端口？大多数 Tracker 不需要我们上报 IPv4 地址，他们可以从 TCP 报文中获取到这个地址。但 Tracker 需要我们上报端口，而 qBittorrent 只会去上报他在内部网络上的端口，因为 qBittorrent 不可能知道通过 NAT 映射后的公网端口是什么。因此，此脚本会将 qBittorent 的监听端口修改为与 NAT 映射后的公网端口一致，让 qBittorrent 上报正确的端口。此脚本还会设置 iptables 端口转发规则。

总的来说，运行 `sudo ./natmap -s stun.stunprotocol.org -h baidu.com -b 45678 -e ./update.sh` 后，脚本会修改 qBittorrent 的监听端口为与公网端口一致，并设置 iptables 端口转发规则，将 `45678` 端口的数据转发至 qBittorrent 监听端口。如果 NAT 映射关系更新（通常由重新拨号造成），NATMap 会再次触发 `update.sh` 脚本，更新端口并设置 iptables 规则。

## 感谢

+ [Natter](https://github.com/MikeWang000000/Natter)
+ [NATMap](https://github.com/heiher/natmap)