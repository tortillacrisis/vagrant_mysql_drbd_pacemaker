#!/bin/bash

# Populate package list (if necessary)

# Install any extra system packages
# sudo yum install docker

sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# Allow IPv4-forwarding
sysctl net.ipv4.ip_forward=1
