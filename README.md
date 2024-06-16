# DeployScript
My own Deploy srcipt for quicly detting up a Ubuntu Server installation

## What this does
1. Aks to change hostname
2. Enables ssh as root (asks to install ssh if not present)
3. Installs NeoFetch
4. add NeoFetch to .bashrc
5. Changes the root password
6. Makes the root terminal prittier by adding NeoFetch every time the shell is loaded and changoing the colors (.baschrc)
7. Asks if you want to install extra components
    1. Docker (with docker-compose)
    2. NodeJS
    3. Apache2
    5. PHP
    4. MariaDB (MySQL)
    5. MongoDB
    6. Python
    7. Java
    8. C/C++ (GCC/G++/Clang)

## Usage
1. Acquire ROOT Shell
```
sudo su 
```
2. Then Download and Run The Script
```
cd /root && wget https://raw.githubusercontent.com/LucaCraft89/DeployScript/main/deploy.sh && chmod 777 deploy.sh && ./deploy.sh
```
Silent Version:
```
cd /root && wget https://raw.githubusercontent.com/LucaCraft89/DeployScript/main/deploy_silent.sh && chmod 777 deploy.sh && ./deploy_silent.sh
```
## Works on
Tested:
- x86_64, amd64 Ubuntu 20.04 LTS / Ubuntu Server 20.04
- x86_64, amd64 Debian Server 9
- Raspberry Pi OS and Raspberry Pi OS Lite on Raspberry Pi 4 and Raspberry Pi 3

Untested:
- Anything that is Debian or Debian-based
