#!/bin/bash

componentInstall()
{
   echo "1. Docker (with docker-compose)"
   echo "2. NodeJS"
   echo "3. Apache2"
   echo "4. MariaDB (MySQL)"
   echo "5. MongoDB"
   echo "6. Python"
   echo "7. Java"
   echo "8. C/C++ (GCC/G++/Clang)"   
   echo "9. ALL"
   read -p "Enter components to install (comma separated): " components
   if [[ $components = "9" ]]
   then
      components="1,2,3,4,5,6,7,8"
   fi
   IFS=',' read -r -a array <<< "$components"
   for element in "${array[@]}"
   do
      if [[ $element = "1" ]]
      then
         clear
         echo "Installing Docker"
         apt-get install docker.io -y
         apt-get install docker-compose -y
      fi
      if [[ $element = "2" ]]
      then
         clear
         echo "Installing NodeJS"
         echo "Select Version"
         echo "1. 12.x"
         echo "2. 14.x"
         echo "3. 16.x (latest)"
         read -p "Enter version: " nodeversion
         if [[ $nodeversion = "1" ]]
         then
            curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
            apt-get install -y nodejs
         fi
         if [[ $nodeversion = "2" ]]
         then
            curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
            apt-get install -y nodejs
         fi
         if [[ $nodeversion = "3" ]]
         then
            curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
            apt-get install -y nodejs
         fi
         echo "Install nvm?"
         read -p "Y/N: " nvm
         if [[ $nvm = "Y" ]]
         then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
         fi
      fi
      if [[ $element = "3" ]]
      then
         clear
         echo "Installing Apache2"
         apt-get install apache2 -y
      fi
      if [[ $element = "4" ]]
      then
         clear
         echo "Installing MariaDB"
         apt-get install mariadb-server -y
      fi
      if [[ $element = "5" ]]
      then
         clear
         echo "Installing MongoDB"
         apt-get install mongodb -y
      fi
      if [[ $element = "6" ]]
      then
         clear
         echo "Installing Python"
         echo "Select Version"
         echo "1. 3.8"
         echo "2. 3.9"
         echo "3. 3.10"
         echo "4. latest"
         read -p "Enter version: " pyversion
         if [[ $pyversion = "1" ]]
         then
            apt-get install python3.8 -y
         fi
         if [[ $pyversion = "2" ]]
         then
            apt-get install python3.9 -y
         fi
         if [[ $pyversion = "3" ]]
         then
            apt-get install python3.10 -y
         fi
         if [[ $pyversion = "4" ]]
         then
            apt-get install python3 -y
         fi
      fi
      if [[ $element = "7" ]]
      then
         clear
         echo "Installing Java"
         echo "Select Version"
         echo "1. 8"
         echo "2. 11"
         echo "3. 16"
         echo "4. latest"
         read -p "Enter version: " javaversion
         if [[ $javaversion = "1" ]]
         then
            apt-get install openjdk-8-jdk -y
         fi
         if [[ $javaversion = "2" ]]
         then
            apt-get install openjdk-11-jdk -y
         fi
         if [[ $javaversion = "3" ]]
         then
            apt-get install openjdk-16-jdk -y
         fi
         if [[ $javaversion = "4" ]]
         then
            apt-get install default-jdk -y
         fi
      fi
      if [[ $element = "8" ]]
      then
         clear
         echo "Installing C/C++"
         apt-get install gcc -y
         apt-get install g++ -y
         apt-get install clang -y
         apt-get install build-essential -y
      fi
   done
   clear
   echo "Reboot?"
   read -p "Y/N: " reboot
   if [[ $reboot = "Y" ]]
   then
      reboot
   fi
   clear
   echo "Exit? (Y/N)"
   read -p "Y/N: " exit_choice
   if [[ $exit_choice = "Y" ]]
   then
      echo "Bye."
      exit 1
   else
      componentInstall
   fi
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, use sudo "$0" instead" 1>&2
   exit 1
fi

clear
echo "Skip to component installation (Skip Deploy)?"

read -p "Y/N: " skip

if [[ $skip = "Y" ]]
then
   echo "Skipping to component installation"
   componentInstall
else
   echo "Proceading.."
fi

echo "Deploying..."

sleep 0.5
clear
echo "Configuration Started"

read -p "MachineNumber (leave blank for current hostname)" hostnumber

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

echo "Enter New root password (leave blank for current password)"

read -p "Password: " pass1

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

apt-get install neofetch -y

neofetch

echo "" >> $bashrc
echo "neofetch" >> $bashrc
echo "" >> $bashrc
echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;32m\]@\[\033[00;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> $bashrc

if [ -d "$DIR" ];
then
   clear
   echo "SSH not installed"
   echo "Install SSH?"
   read -p "Y/N: " sshinstall
   if [[ $sshinstall = "Y" ]]
   then
      apt-get install openssh-server -y
   else
      echo "Skipping SSH install"
   fi
else
   sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" $sshconf

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

echo "Enter additional componens installation?"
read -p "Y/N: " addinstall
if [[ $addinstall = "Y" ]]
then
   clear
   componentInstall
else
   echo "Skipping additional components installation"
fi
sleep 0.5
clear
echo "Reboot? (Note: Rebooting required to change the hostname)"
read -p "Y/N: " reboot
if [[ $reboot = "Y" ]]
then
   reboot
fi
echo "Bye."
