#!/bin/bash
# Vars
skip=false #Skip Deployment
changehostname = true #Change Hostname
hostnumber = "19" #Host Number
changepass = true #Change Root Password
pass1 = "Luc41312!" #Root Password
addinstall = true #Additional Components Installation
componentInstall()
{
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
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
      
      IFSS=',' read -r -a nodevers <<< "$versions"
      for version in "${nodevers[@]}"
      do
         nvm install $version
      done        
   fi
   if $apache2
   then
      apt-get install apache2 -y
      if $php
      then
         apt-get install php libapache2-mod-php php-mysql -y
      fi
   fi
   if $mariadb
   then
      apt-get install mariadb-server -y
   fi
   if $mongodb
   then
      apt-get install mongodb -y
   fi
   if $python
   then
      apt-get install python$pyversion -y
   fi
   if $java
   then
      if [[ $javaversion = "latest" ]]
      then
         apt-get install default-jdk -y
      else
         apt-get install openjdk-$javaversion-jdk -y
      fi
   fi
   if $c
   then
      apt-get install gcc -y
      apt-get install g++ -y
      apt-get install clang -y
      apt-get install build-essential -y
   fi
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, use sudo "$0" instead" 1>&2
   exit 1
fi

if $skip
then
   if $addinstall
   then
      componentInstall
   else
      exit 1
   fi
fi

if $changepass
then
   chpasswd <<<"root:$pass1"
fi

if $changehostname
then
else
   hostname="linux"$hostnumber
   hostnamectl set-hostname $hostname
fi

bashrc="/root/.bashrc"

sshdir="/etc/ssh"

sshconf="/etc/ssh/sshd_config"

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
   apt-get install openssh-server -y
else
   sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" $sshconf

   ufw allow ssh

   systemctl restart ssh.service

   systemctl restart sshd.service
fi
apt-get upgrade -y
if $addinstall
then
   componentInstall
fi
reboot
