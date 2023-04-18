#!/bin/bash

ip=$(hostname -I | cut -f1 -d' ')

bashrc="/root/.bashrc"

sshdir="/etc/ssh"

sshconf="/etc/ssh/sshd_config"

echo "Deploing in 5 seconds"

sleep 5

echo "Deploying..."

sleep 0.5

echo "Configuration Started"

echo "Enter New root password (leave blank for K0v4lsk1!)"

read -p "Password: " pass1

if [[ $pass1 = "" ]]
then
   pass1="K0v4lsk1!"
fi

echo "New root password: " $pass1

sleep 0.7

echo "Configuration Ended. Automated install from now."

sleep 0.3

echo "Proceading.."

sleep 0.5

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, use sudo "$0" instead" 1>&2
   exit 1
fi

cd /root/

apt-get install neofetch -y

neofetch

echo "" >> $bashrc
echo "neofetch" >> $bashrc
echo "" >> $bashrc
echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;32m\]@\[\033[00;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> $bashrc

if [ -d "$DIR" ];
then
   echo "SSH not installed skipping"
   exit 1
fi

sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" $sshconf

systemctl restart ssh.service

systemctl restart sshd.service

chpasswd <<<"root:$pass1"

echo "Deploy finished"

echo "--------------SSH Connection details--------------"

echo ""
echo ""

echo "ssh root@$ip"
echo ""
echo "$pass1"

echo ""
echo ""

echo "--------------------------------------------------"

echo "Bye."
