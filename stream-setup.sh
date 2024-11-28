#!/bin/bash

# Tailscale install and activation
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update
sudo apt-get install -y tailscale cifs-utils
sudo tailscale login

curl -fsSL https://raw.githubusercontent.com/sloppy-carlton/miniature-guide/refs/heads/main/tailscale/tailscale.service | sudo tee /etc/systemd/system/tailscale.service > /dev/null
sudo systemctl daemon-reload
sudo systemctl enable --now tailscale.service

# Enable Tailscale NAS access
echo "Enter NAS username:";
read username
echo "Enter NAS password:";
read -s password

echo username=$username | sudo tee /etc/.nascredentials > /dev/null
echo password=$password | sudo tee /etc/.nascredentials > /dev/null
unset password
unset username

sudo mkdir /mnt/media

echo "//100.117.113.2/Public /mnt/media cifs credentials=/etc/.nascredentials,vers=3.0,uid=1000,gid=1000,rw,exec,_netdev,x-systemd.automount 0 0" | sudo tee /etc/fstab > /dev/null

sudo systemctl daemon-reload
sudo mount -a

# Jellyfin
curl https://repo.jellyfin.org/install-debuntu.sh | sudo bash

# Navidrome
sudo apt update
sudo apt upgrade
sudo apt install vim ffmpeg
sudo install -d -o 1000 -g 1000 /opt/navidrome
sudo install -d -o 1000 -g 1000 /var/lib/navidrome
wget https://github.com/navidrome/navidrome/releases/download/v0.XX.X/navidrome_0.XX.X_linux_amd64.tar.gz -O Navidrome.tar.gz
sudo tar -xvzf Navidrome.tar.gz -C /opt/navidrome/
sudo chown -R 1000:1000 /opt/navidrome
echo 'MusicFolder= "/mnt/media/Music"' > /var/lib/navidrome
curl -fsSL https://raw.githubusercontent.com/sloppy-carlton/miniature-guide/refs/heads/main/navidrome/navidrome.service | sudo tee /etc/systemd/system/navidrome.service
sudo systemctl daemon-reload
sudo systemctl enable --now navidrome.service
