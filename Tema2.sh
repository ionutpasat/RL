#----Host-----#
auto to-pc-x
iface to-pc-x inet static
	address 172.18.92.9
	netmask 255.255.255.248

auto to-router0
iface to-router0 inet static
        address 172.18.92.17
        netmask 255.255.255.252
	up ip route add 10.11.86.0/28 via 172.18.92.18
	up ip -6 address add FEC0:1234:92:71::1/64 dev to-router0
	up ip -6 route add 2022:12:86:92::/64 via fec0:1234:92:71::2
	up cat /etc/myhosts > /etc/hosts
	up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	up iptables -t nat -A PREROUTING -p tcp --dport 21042 -j DNAT --to-destination 10.11.86.2:22
	up iptables -t nat -A PREROUTING -p tcp --dport 22220 -j DNAT --to-destination 10.11.86.3:22
	up iptables -t nat -A PREROUTING -p udp --dport 12388 -j DNAT --to-destination 172.18.92.10:8925
	up iptables -t nat -A PREROUTING -p udp --dport 12388 -j DNAT --to-destination 172.18.92.10:41337
	up iptables -A OUTPUT -p tcp -d 10.11.86.2 --dport 25 -j DROP

127.0.0.1 localhost
127.0.1.1       host
172.18.92.18 Router0
10.11.86.2 PC1
10.11.86.3 PC2
172.18.92.10 PC-X

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

#----PCX----#
auto to-host
iface to-host inet static
    address 172.18.92.10
    netmask 255.255.255.248
    gateway 172.18.92.9
    up cat /etc/myhosts > /etc/hosts
    up wg-quick up /etc/wireguard/wg-rl.conf
    up iptables -t nat -A POSTROUTING -o wg-rl -j MASQUERADE
    up iptables -t nat -A PREROUTING -p tcp --dport 666 -j DNAT --to-destination 10.99.116.2:16661

127.0.0.1 localhost PC-X
172.18.92.9 Host
10.11.86.2 PC1
10.11.86.3 PC2
172.18.92.18 Router0
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters

[Interface]
Address = 10.99.116.1/24
ListenPort = 51820
PrivateKey = oHvRzD0V/6tTkhb3ZIp5tgJXfINYZbsnwtkgzKfqLWM=

[Peer]
PublicKey = eXW/YMefmBED1bNXrYbSrp8cTgOd59Ni6smICGCC434=
AllowedIPs = 10.99.116.2/32

#----Router----#
auto to-host
iface to-host inet static
    address 172.18.92.18
    netmask 255.255.255.252
    gateway 172.18.92.17
    up ip route add 172.18.92.0/29 via 172.18.92.17
    up ip -6 address add FEC0:1234:92:71::2/64 dev to-host
    up ip -6 address add 2022:12:86:92::1/64 dev br0
    up cat /etc/myhosts > /etc/hosts
    up iptables -t nat -A PREROUTING -p tcp --dport 21042 -i to-host -j DNAT --to-destination 10.11.86.2:22
    up iptables -t nat -A PREROUTING -p tcp --dport 22220 -i to-host -j DNAT --to-destination 10.11.86.3:22
    up iptables -A FORWARD -p udp -s 10.11.86.3 --dport 8925 -j DROP
    up iptables -A OUTPUT -p tcp -d 10.11.86.2 --dport 25 -j DROP
    up iptables -A FORWARD -p icmp -d 10.11.86.2,10.11.86.3 -m state --state NEW,ESTABLISHED -j ACCEPT
    up iptables -A FORWARD -p tcp --dport 22 -d 10.11.86.2,10.11.86.3 -m state --state NEW,ESTABLISHED -j ACCEPT
    up iptables -A FORWARD -p tcp --dport 21 -d 10.11.86.2,10.11.86.3 -m state --state NEW,ESTABLISHED -j ACCEPT
    up iptables -A FORWARD -d 10.11.86.2,10.11.86.3 -m state --state NEW -j DROP

127.0.0.1 localhost Router0
172.18.92.17 Host
10.11.86.2 PC1
10.11.86.3 PC2
172.18.92.10 PC-X

::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters

#----PC1----#
auto to-router0
iface to-router0 inet static
    address 10.11.86.2
    netmask 255.255.255.240
    gateway 10.11.86.1
    up ip -6 address add 2022:12:86:92::2/64 dev to-router0
    up cat /etc/myhosts > /etc/hosts

127.0.0.1 localhost PC1
172.18.92.17 Host
10.11.86.1 Router0
10.11.86.3 PC2
172.18.92.10 PC-X

::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters

#----PC2----#
auto to-router0
iface to-router0 inet static
    address 10.11.86.3
    netmask 255.255.255.240
    gateway 10.11.86.1
    up ip -6 address add 2022:12:86:92::3/64 dev to-router0
    up cat /etc/myhosts > /etc/hosts
    up wg-quick up /etc/wireguard/wg-rl.conf

127.0.0.1 localhost PC2
172.18.92.17 Host
10.11.86.2 PC1
10.11.86.1 Router0
172.18.92.10 PC-X

::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters

[Interface]
Address = 10.99.116.2/24
PrivateKey = KLaBnCsZgMypUoevNe92ZvjP5V5kSA0NbXi718LoUE0=

[Peer]
PublicKey = qBTP/Rs8rDk4lL5ddIPbdeQGFeonaz27RBL5GZ/dNg8=
AllowedIPs = 10.99.116.0/24
Endpoint = 172.18.92.10:51820

#----whereswaldo----#
#!/bin/bash

base_url="http://host/.X/"
filename="waldo.txt"
user="ana"
password="face_ReLe"

wget --user "$user" --password "$password" -qr -np -nd --level=inf --accept "$filename" --directory-prefix=. "$base_url"

if [ -f "$filename" ]; then
  cat "$filename"
  rm "$filename"
else
  echo "File not found"
fi

#----file-upload----#
#!/bin/bash

password="3TaLeNt1337"
user="fs"
remote_host="pc1"
remote_dir="/home/fs/upload"
files=$(find . -regextype posix-egrep -regex "./this([XYZ])_([0-9]{1,5}).txt")

for file in $files
do
  sshpass -p "$password" scp $file "$user"@"$remote_host":"$remote_dir"
done

#----file-download----#
#!/bin/bash

password="student"
user="student"
remote_host="pc-x"
remote_dir="/home/student/download-this"
pattern="./([0-9]+)-([a-zA-Z0-9]+)\.tar\.gz"
files=$(sshpass -p "$password" ssh "$user@$remote_host" "cd download-this && find . -regextype posix-egrep -regex '$pattern'")

for file in $files
do
  sshpass -p "$password" scp "$user@$remote_host:$remote_dir${file:1}" .
done

#----ssh-keys-backup----#
#!/bin/bash
tar -czf ssh-keys.tar.gz /home/student/.ssh/*
hash=$(sha256sum ssh-keys.tar.gz | awk '{print $1}')

message="The SHA256 hash of the attachment is $hash"
echo "$message" > mssg
mutt -s "SSH Keys Backup" contact@host -a ./ssh-keys.tar.gz < mssg
rm mssg
rm ssh-keys.tar.gz


