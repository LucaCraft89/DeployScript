#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, use sudo "$0" instead" 1>&2
   exit 1
fi
clear
echo "Deploying..."
sleep 0.5
clear
echo "Configuration Started"
sleep 0.8
clear
echo "MachineNumber hostname will be linux{MachineNumber}"
echo "Leave Blank to skip, Current hostname: " $(hostname)
read -p "->" hostnumber

if [[ $hostnumber = "" ]]; then
   echo "Current hostname: " $(hostname)
else
   hostname="linux"$hostnumber
   echo "New hostname: " $hostname
   echo "Changing hostname..."
   sleep 0.5
   hostnamectl set-hostname $hostname
   echo "Hostname changed to: " $hostname
   sleep 0.5
fi

ip=$(hostname -I | cut -f1 -d' ')
bashrc="/root/.bashrc"
sshdir="/etc/ssh"
sshconf="/etc/ssh/sshd_config"

clear
echo "Enter New root password"
echo "Leave Blank to Skip (you may need to set a password to access SSH)"
read -p "->" pass1

if [[ $pass1 = "" ]]; then
   echo "Leaving password unchanged"
   sleep 1.5
else
   chpasswd <<<"root:$pass1"
fi

sleep 0.7
clear

cd /root/
apt update -y
apt install neofetch qemu-guest-agent curl wget git -y

if [ -z "$DISPLAY" ]; then
   echo "Display not found, skipping SPICE agent install"
else
   apt install spice-vdagent -y
fi

neofetch
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
mv git-prompt.sh .git-prompt.sh
clear

line1="neofetch"
line2="source ~/.git-prompt.sh"
line3="PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 " (%s)")'; PS1='\[\e[2m\]\D{%Y/%m/%d}\[\e[0m\] \[\e[36m\]\t\[\e[0m\] \[\e[91;1m\]\u\[\e[0m\]@\[\e[92m\]\H\[\e[0m\]:\[\e[96m\]\w\[\e[95m\]${PS1_CMD1}\[\e[0m\]:\n\$'"

clear
echo "Do you wish to make the terminal pretty?"

read -p "Y/N: " pretty

if [[ $pretty = "Y" ]]; then
   if grep -Fxq "$line1" $bashrc && grep -Fxq "$line2" $bashrc && grep -Fxq "$line3" $bashrc; then
      echo "Lines are already in $bashrc, skipping addition"
   else
      echo "" >>$bashrc
      echo "$line1" >>$bashrc
      echo "" >>$bashrc
      echo "$line2" >>$bashrc
      echo "" >>$bashrc
      echo "$line3" >>$bashrc
   fi
else
   echo "Skipping root terminal configuration"
fi
clear
echo "Do you wish to make other users terminals pretty?"
echo "Write the usernames comma separated, leave blank to skip"
read -p "->" users

if [[ $users = "" ]]; then
   echo "Skipping user terminal configuration"
else
   for user in $(echo $users | sed "s/,/ /g"); do
      if [ -d "/home/$user" ]; then
         echo "Configuring $user\'s terminal"
         userbashrc="/home/$user/.bashrc"
         cp /root/.git-prompt.sh /home/$user/.git-prompt.sh
         if grep -Fxq "$line1" $userbashrc && grep -Fxq "$line2" $userbashrc && grep -Fxq "$line3" $userbashrc; then
            echo "Lines are already in $userbashrc, skipping addition"
         else
            echo "" >>$userbashrc
            echo "$line1" >>$userbashrc
            echo "" >>$userbashrc
            echo "$line2" >>$userbashrc
            echo "" >>$userbashrc
            echo "$line3" >>$userbashrc
         fi
      else
         echo "User $user does not exist"
      fi
   done
fi
sleep 1
clear

sshconfig() {
   sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" $sshconf
   sed -i "s/#Subsystem      sftp    \/usr\/lib\/openssh\/sftp-server/Subsystem      sftp    internal-sftp/" $sshconf
   sed -i "s/Subsystem      sftp    \/usr\/lib\/openssh\/sftp-server/Subsystem      sftp    internal-sftp/" $sshconf
   ufw allow ssh
   systemctl restart ssh.service
   systemctl restart sshd.service
}

if [ -d "$DIR" ]; then
   clear
   echo "SSH not installed"
   echo "Install SSH?"
   read -p "Y/N: " sshinstall
   if [[ $sshinstall = "Y" ]]; then
      apt-get install openssh-server -y
      sshconfig
   else
      echo "Skipping SSH install"
   fi
else
   sshconfig
fi

clear
echo "Deploy finished"
echo "----------------------- Details ------------------"
echo ""
echo "IP Address: $ip"
echo ""
echo "Hostname: $hostname"
echo ""
echo "--------------------------------------------------"
sleep 0.5
clear
echo "Reboot?"
echo "Rebooting required to change the hostname"
read -p "Y/N: " reboot
if [[ $reboot = "Y" ]]; then
   reboot
fi
echo "Bye."
