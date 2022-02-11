#!/bin/bash

script_relative_path1=$(dirname $0)
script_name=$(basename $0)

script="$script_relative_path1/$script_name"

sudo chmod 777 $script

echo Hello, who am I talking to?

read -p 'Full-Name: ' varAdminName

while true; do
    read -r -p "It's nice to meet you $varAdminName. We'll install a few updates before we start off?(y/N)" varAns
    case $varAns in
    [yY][eE][sS] | [yY])
        sudo apt update -y && sudo apt upgrade -y
        break
        ;;
    [nN][oO] | [nN])
        echo "No worries, you could always do it later yourself."
        break
        ;;
    *)
        echo "Invalid input..."
        ;;
    esac
done

publicIp=$(curl ifconfig.me)

echo would you like to create a new admin user?\(y\/N\)
while true; do
    read -r -p "So, $varAdminName, would you like to create a new admin user?(y/N)" varAns
    case $varAns in
    [yY][eE][sS] | [yY])
        echo creating a new admin user, what \do you want your username to be?
        read -p 'Username: ' varUser
        adduser $varUser
        usermod -aG sudo $varUser
        sudo passwd -l root
        sudo su -u "$varUser" -c "sudo sh $script"
        break
        ;;
    [nN][oO] | [nN])
        echo "No worries, you could always do it later yourself."
        break
        ;;
    *)
        echo "Invalid input..."
        ;;
    esac
done

cd
# setting timezone and automatic upgrades
sudo dpkg-reconfigure tzdata
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot-Time "03:30";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades

read -r -p "Configuring Network stack TCP buffers and states

buffer size = network capacity * round trip time

For example, if the ping time is 30 milliseconds and the network consists of 1G Ethernet then the buffers should be as follows:

.03 sec X (1024 Megabits) X (1/8)= 3.84 MegaBytes. Enter the buffer size in bits: " varBuffer

sudo sysctl -w net.core.rmem_max=$varBuffer
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 $varBuffer"
sudo sysctl -w net.core.wmem_max=$varBuffer
sudo sysctl -w net.ipv4.tcp_wmem="4096 16384 $varBuffer"

sudo sysctl -w net.ipv4.tcp_congestion_control=cubic

sudo sysctl -w net.ipv4.tcp_fin_timeout=20

sudo sysctl -w net.ipv4.tcp_tw_reuse=1

sudo sysctl -w net.core.netdev_max_backlog=10000

sudo sysctl -w net.core.somaxconn=4096

sudo sysctl -w net.ipv4.tcp_max_syn_backlog=2048

sudo sysctl -w net.ipv4.ip_local_port_range='15000 65000'

echo "
*                soft    nofile          64000
*                hard    nofile          64000
" | sudo tee -a /etc/security/limits.conf
