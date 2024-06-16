#!/bin/bash
# Vars
skip=false #Skip Deployment
hostnumber = "19" #Host Number
pass1 = "Luc41312!" #Root Password
addinstall = true #Additional Components Installation
componentInstall()
{
   clear
   #COMPONENTS
   #"1. Docker (with docker-compose)"
   docker=true
   #"2. NodeJS"
   node=true
   versions="14.17.6,16.9.1" # Default to latest LTS and latest
   #"3. Apache2"
   apache2=true
   php=true
   #"4. MariaDB (MySQL)"
   mariadb=true
   #"5. MongoDB"
   mongodb=true
   #"6. Python"
   python=true
   pyversion="3" # Default to latest
   #"7. Java"
   java=true
   javaversion="latest" # Default to latest
   #"8. C/C++ (GCC/G++/Clang)"   
   c=true
   if $docker
   then
      clear
      echo "Installing Docker"
      sudo apt-get update
      sudo apt-get install ca-certificates curl -y
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc
      echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
   fi
   if $node
   then
      echo "Installing nvm"
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
      clear
      echo "Installing NodeJS"
      echo "Versions: $versions"
      IFSS=',' read -r -a nodevers <<< "$versions"
      for version in "${nodevers[@]}"
      do
         nvm install $version
      done        
   fi
   if $apache2
   then
      clear
      echo "Installing Apache2"
      apt-get install apache2 -y
      if $php
      then
         clear
         echo "Installing PHP"
         apt-get install php libapache2-mod-php php-mysql -y
      fi
   fi
   if $mariadb
   then
      clear
      echo "Installing MariaDB"
      apt-get install mariadb-server -y
   fi
   if $mongodb
   then
      clear
      echo "Installing MongoDB"
      apt-get install mongodb -y
   fi
   if $python
   then
      clear
      echo "Installing Python $pyversion"
      apt-get install python$pyversion -y
   fi
   if $java
   then
      clear
      echo "Installing Java (OpenJDK) $javaversion"
      if [[ $javaversion = "latest" ]]
      then
         apt-get install default-jdk -y
      else
         apt-get install openjdk-$javaversion-jdk -y
      fi
   fi
   if $c
   then
      clear
      echo "Installing C/C++"
      apt-get install gcc -y
      apt-get install g++ -y
      apt-get install clang -y
      apt-get install build-essential -y
   fi

   clear
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, use sudo "$0" instead" 1>&2
   exit 1
fi

clear

if $skip
then
   echo "Skipping to component installation"
   if $addinstall
   then
      clear
      componentInstall
   else
      echo "Skipping additional components installation"
      exit 0
   fi
else
   echo "Proceading.."
fi

echo "Deploying..."

sleep 0.5
clear
echo "Configuration Started"

if [[ $hostnumber = "" ]]
then
   echo "Current hostname: " $(hostname)
else
   echo "MachineNumber: " $hostnumber

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


if [[ $pass1 = "" ]]
then
   echo "Leaving password unchanged (You may not be able to access SSH without changing it first)"
   sleep 1.5
else
   chpasswd <<<"root:$pass1" 
fi

sleep 0.7

echo "Configuration Ended. Automated install from now."

sleep 0.3

echo "Proceading.."

sleep 0.5

cd /root/

apt-get update -y

apt-get install neofetch qemu-guest-agent -y

neofetch

wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

mv git-prompt.sh .git-prompt.sh

line1="neofetch"
line2="source ~/.git-prompt.sh"
line3="PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 " (%s)")'; PS1='\[\e[2m\]\D{%Y/%m/%d}\[\e[0m\] \[\e[36m\]\t\[\e[0m\] \[\e[91;1m\]\u\[\e[0m\]@\[\e[92m\]\H\[\e[0m\]:\[\e[96m\]\w\[\e[95m\]${PS1_CMD1}\[\e[0m\]:\n\$'"
if grep -Fxq "$line1" $bashrc && grep -Fxq "$line2" $bashrc && grep -Fxq "$line3" $bashrc
then
    echo "Lines are already in bashrc, skipping addition"
else
    echo "" >> $bashrc
    echo "$line1" >> $bashrc
    echo "" >> $bashrc
    echo "$line2" >> $bashrc
    echo "" >> $bashrc
    echo "$line3" >> $bashrc
fi

if [ -d "$sshdir" ];
then
   clear
   echo "SSH not installed"
   apt-get install openssh-server -y
else
   sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" $sshconf

   ufw allow ssh

   systemctl restart ssh.service

   systemctl restart sshd.service
fi

clear
echo "Deploy finished"


echo "----------------------- Details ------------------"

echo ""
echo ""

echo "IP Address: $ip"
echo ""
echo "Hostname: $hostname"

echo ""
echo ""

echo "--------------------------------------------------"
apt-get upgrade -y
if $addinstall
then
   clear
   componentInstall
else
   echo "Skipping additional components installation"
fi
sleep 0.5
clear
echo "Rebooting..."
reboot
