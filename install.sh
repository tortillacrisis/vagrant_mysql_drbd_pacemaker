#!/bin/bash
# 

echo "########################################"
echo "# Installs necessary packages"
echo "########################################"

echo "Install Ntp"
sudo yum install ntp -y &>/dev/null

echo "Install corosync"
sudo yum install corosync -y &>/dev/null

echo "Install wget, in order to download sshpass"
sudo yum install wget -y &>/dev/null

echo "fetch and install sshpass, as it's not in any official cento7 repo"
cd /tmp
# wget http://dl.fedoraproject.org/pub/epel/6/x86_64/sshpass-1.05-1.el6.x86_64.rpm
wget ftp://ftp.muug.mb.ca/mirror/fedora/epel/6/x86_64/sshpass-1.05-1.el6.x86_64.rpm  &>/dev/null
rpm -ivh sshpass-1.05-1.el6.x86_64.rpm  &>/dev/null
cd -

echo "Install pacemaker"
sudo yum install pacemaker -y &>/dev/null
sudo yum install pcs -y &>/dev/null

echo "Stop the existing firewall daemon"
sudo systemctl stop firewalld &>/dev/null
sudo systemctl mask firewalld &>/dev/null

echo "Install the iptables-services package"
sudo yum install iptables-services &>/dev/null
sudo systemctl enable iptables &>/dev/null
sudo systemctl start iptables  &>/dev/null

echo "Install expect"
sudo yum install expect -y &>/dev/null



echo "########################################"
echo "# Configure Firewall"
echo "########################################"
# TODO - switch back to the firewalld
echo "Open UDP-ports 5404 and 5405 for Corosync:"

sudo iptables -I INPUT -m state --state NEW -p udp -m multiport --dports 5404,5405 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -p udp -m multiport --dports 5404,5405 -j ACCEPT

echo "Open TCP-port 2224 for PCS"

sudo iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 2224 -j ACCEPT
sudo iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 2224 -j ACCEPT

echo "Allow IGMP-traffic"

sudo iptables -I INPUT -p igmp -j ACCEPT
sudo iptables -I INPUT -p igmp -j ACCEPT
# firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p igmp -j ACCEPT

echo "Allow multicast-traffic"

sudo iptables -I INPUT -m addrtype --dst-type MULTICAST -j ACCEPT
sudo iptables -I INPUT -m addrtype --dst-type MULTICAST -j ACCEPT
#firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" destination address="224.0.0.18" protocol value="ip" accept'

sudo iptables-save > /tmp/iptables
sudo cp /tmp/iptables /etc/sysconfig/iptables
