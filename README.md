# DeployScript
My own Deploy srcipt for quicly detting up a Ubuntu Server installation

## What this does
1. Enables ssh ad root
2. Installs NeoFetch
3. Changes the root password
4. Makes the root terminal prittier by adding NeoFetch every time the shell is loaded and changoing the colors (.baschrc)

## Installation
1. Acquire ROOT Shell
```
sudo su 
```
2. Then Download and Run The Script
```
cd /root && wget https://raw.githubusercontent.com/LucaCraft89/DeployScript/main/deploy.sh && chmod 777 deploy.sh && ./deploy.sh
```

## Works on
Tested:
- x86_64, amd64 Ubuntu 20.04 LTS / Ubuntu Server 20.04
- x86_64, amd64 Debian Server 9
- Raspberry Pi OS and Raspberry Pi OS Lite on Raspberry Pi 4 and Raspberry Pi 3

Untested:
- Anything that is Debian or Debian-based
