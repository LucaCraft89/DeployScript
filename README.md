# DeployScript
My own Deploy srcipt for quicly setting up a Debian-based Linux Server VM installation on a Proxmox host 

## What does this do?
1. Prompts to change the following
    - hostname
    - root password
    - terminal prettieness
    - install ssh if absent
    - reboot
2. Allows root ssh login
3. Sets sftp server to internal-sftp
5. Installs:
    - neofetch
    - qemu-guest-agent
    - spice-vdagent if display is present
    - curl, wget and git

## Usage
1. Acquire root shell (avoid using sudo)
```shell
#For suduores (user password)
sudo su 
```
```shell
#For non sudoeers (root password)
su -
```
2. Pull, adjust permissions, execute
```shell
# With curl (recomended)
cd /root && rm -f deploy*.sh && curl https://raw.githubusercontent.com/LucaCraft89/DeployScript/main/deploy.sh -o deploy.sh && chmod +x deploy.sh && ./deploy.sh
```
```shell
# With wget
cd /root && rm -f deploy*.sh && wget https://raw.githubusercontent.com/LucaCraft89/DeployScript/main/deploy.sh && chmod +x deploy.sh && ./deploy.sh
```

## Works on
Tested:
- amd64 Ubuntu 20.04, 22.04, 24.04
- amd64 Debian 9, 12
- Raspberry Pi OS and Raspberry Pi OS Lite on Raspberry Pi 3, 4, 5

Untested:
- Anything that is Debian or Debian-based
