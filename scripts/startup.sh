#!/bin/bash

touch /test
yum update -y
yum install -y docker vim nmap tcpdump
service docker start
usermod -a -G docker ec2-user


# wg
yum install -y wget
#yum upgrade
amazon-linux-extras install -y epel
export rwfile="/etc/yum.repos.d/wireguard.repo"
export rwurl="https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo"
wget --output-document="$rwfile" "$rwurl"
yum clean all
yum install -y wireguard-dkms wireguard-tools

