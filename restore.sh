#!/bin/bash
clear
echo -e "\e[1;36m
 ____  _____ _     ___ _______     _______ ____  
| __ )| ____| |   |_ _| ____\ \   / / ____|  _ \ 
|  _ \|  _| | |    | ||  _|  \ \ / /|  _| | |_) |
| |_) | |___| |___ | || |___  \ V / | |___|  _ < 
|____/|_____|_____|___|_____|  \_/  |_____|_| \_\
                                                 
\e[0m"

INTERFACE="wlan0"

echo "[*] Bringing interface down..."
sudo ip link set "$INTERFACE" down

echo "[*] Restoring original MAC..."
sudo macchanger -p "$INTERFACE" || exit 1

echo "[*] Bringing interface up..."
sudo ip link set "$INTERFACE" up

echo "[*] Requesting DHCP IP..."
sudo dhclient "$INTERFACE"

echo "[+] Restored:"
ip addr show "$INTERFACE" | grep -E 'inet |ether'
