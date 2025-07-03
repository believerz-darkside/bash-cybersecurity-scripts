#!/bin/bash

# === BELIEVER Banner ===
clear
echo -e "\e[1;36m
 ____  _____ _     ___ _______     _______ ____  
| __ )| ____| |   |_ _| ____\ \   / / ____|  _ \ 
|  _ \|  _| | |    | ||  _|  \ \ / /|  _| | |_) |
| |_) | |___| |___ | || |___  \ V / | |___|  _ < 
|____/|_____|_____|___|_____|  \_/  |_____|_| \_\
                                                 

\e[0m"

INTERFACE="wlan0"

# === DEP CHECK ===
for cmd in macchanger ip; do
  if ! command -v $cmd &>/dev/null; then
    echo "[!] Missing: $cmd. Install first." >&2
    exit 1
  fi
done

# === SPOOF START ===
echo "[*] Bringing interface down..."
sudo ip link set "$INTERFACE" down || exit 1

echo "[*] Spoofing MAC..."
sudo macchanger -r "$INTERFACE" || exit 1

echo "[*] Bringing interface up..."
sudo ip link set "$INTERFACE" up || exit 1

echo "[*] Requesting DHCP IP..."
sudo dhclient "$INTERFACE" || echo "[!] dhclient may not be available. Use static IP if needed."

echo "[+] New config:"
ip addr show "$INTERFACE" | grep -E 'inet |ether'
