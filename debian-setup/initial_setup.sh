#!/bin/bash

cat > /etc/ssh/sshd_config.d/pi_ssh.conf << END
Port 2022
HostKey /etc/ssh/ssh_host_ecdsa_key
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile  .ssh/authorized_keys
PasswordAuthentication yes
ChallengeResponseAuthentication yes
X11Forwarding yes
END

apt update
apt full-upgrade -y
apt install curl wget vim apt-transport-https ca-certificates gnupg haveged -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
mkdir ./unifi-controller
chown cc:cc ./unifi-controller
cd ./unifi-controller

cat > ./docker-compose.yml << END
version: '3.9'

services:
  controller:
    image: jacobalberty/unifi:latest
    container_name: unifi_controller
    init: true
    user: unifi
    sysctls:
      net.ipv4.ip_unprivileged_port_start: 0
    ports:
      - "3478:3478/udp" # STUN
      - "6789:6789/tcp" # Speed test
      - "8080:8080/tcp" # Device/ controller comm.
      - "8443:8443/tcp" # Controller GUI/API as seen in a web browser
      - "8880:8880/tcp" # HTTP portal redirection
      - "8843:8843/tcp" # HTTPS portal redirection
      - "10001:10001/udp" # AP discovery
    volumes:
      - dir:/unifi
      - data:/unifi/data
      - log:/unifi/log
      - cert:/unifi/cert
      - init:/unifi/init.d
      - run:/var/run/unifi
      - ./backup:/unifi/data/backup
    environment:
      TZ: America/Los_Angeles
    restart: unless-stopped
    
volumes:
  data:
  log:
  cert:
  init:
  dir:
  run:
END

chown cc:cc ./docker-compose.yml

echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | tee /etc/apt/sources.list.d/azlux.list
wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
apt update
apt install log2ram -y

echo "Jobs done"