#!/bin/bash
set -e

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing WireGuard and dependencies..."
sudo apt install -y wireguard wireguard-tools qrencode

echo "Enabling IP forwarding..."
# Enable IPv4 forwarding
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
# Enable IPv6 forwarding (optional; uncomment if you need IPv6)
sudo sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/' /etc/sysctl.conf
sudo sysctl -p

echo "Generating server keys..."
SERVER_PRIVATE_KEY=$(wg genkey)
SERVER_PUBLIC_KEY=$(echo "$SERVER_PRIVATE_KEY" | wg pubkey)

echo "Creating WireGuard configuration file at /etc/wireguard/wg0.conf..."
sudo bash -c "cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRIVATE_KEY
# SaveConfig = true

# Example Peer configuration (uncomment and modify for client setups)
#[Peer]
#PublicKey = <client_public_key>
#AllowedIPs = 10.0.0.2/32
EOF"

echo "WireGuard installation complete."
echo "Server Public Key: $SERVER_PUBLIC_KEY"
