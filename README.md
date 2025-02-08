# VPN WireGuard on Vultr

## 1. Title and Introduction
- **Title:** VPN WireGuard on Vultr
- **Introduction:**
  - Documentation of setting up a secure VPN using WireGuard on a Vultr cloud instance.
  - Part of a cybersecurity portfolio.

## 2. Overview
- **Project Demonstrates:**
  - Provisioning a Debian-based server on Vultr.
  - Installing and configuring WireGuard.
  - Setting up NAT and IP forwarding for full-tunnel VPN access.
  - Generating and configuring client keys and configurations.
  - Testing connectivity.

## 3. Project Structure
- **Files and Directories:**
  - `README.md`
  - `docs/`
    - `outline.md` – Detailed project roadmap and step-by-step instructions.
    - `usage.md` – Deployment and usage guide for the VPN.
  - `scripts/`
    - `install-wireguard.sh` – Script to install and configure WireGuard on the server.
  - `config/`
    - `wg0.conf.sample` – Sample server configuration file.
    - `wg0-client.conf.sample` – Sample client configuration file.
  - `screenshots/`
    - `server_config.png` – Screenshot of server configuration and NAT setup.
    - `client_connection.png` – Screenshot of client VPN connection status.

## 4. Requirements
- Vultr account with a Debian-based instance (Debian 12 recommended)
- SSH access and sudo privileges on the server
- Basic familiarity with Linux command-line operations
- A client device (e.g., Mac) with the WireGuard client installed

## 5. Installation & Setup

### 5.1 Server Setup
- **Provision the Vultr Instance:**
  - Deploy a new Debian 12 instance.
  - Minimum specs: 1 vCPU, 1 GB RAM, 25 GB SSD.
  - Add your SSH key during provisioning.
- **Clone the Repository on the Server:**
  - Command: `git clone https://github.com/chetflowers/vpn-wireguard-vltr.git`
  - Change directory: `cd vpn-wireguard-vltr`
- **Run the WireGuard Installation Script:**
  - Navigate to scripts: `cd scripts`
  - Run: `./install-wireguard.sh`
  - *Script Actions:*
    - Updates system packages.
    - Installs WireGuard and dependencies.
    - Enables IP forwarding.
    - Generates server keys.
    - Creates `/etc/wireguard/wg0.conf`.
- **Enable & Start WireGuard:**
  - Commands:
    - `systemctl enable wg-quick@wg0`
    - `systemctl start wg-quick@wg0`
- **Set Up NAT (Masquerading):**
  - Identify the public network interface (e.g., `enp1s0`).
  - Command: `iptables -t nat -A POSTROUTING -o enp1s0 -j MASQUERADE`
  - Ensure `/etc/sysctl.conf` includes: `net.ipv4.ip_forward=1` (apply with `sysctl -p`)

### 5.2 Client Setup
- **Generate Client Keys:**
  - Command: `wg genkey | tee client_private.key | wg pubkey > client_public.key`
- **Configure the Client:**
  - Edit `config/wg0-client.conf.sample` with:
    ```ini
    [Interface]
    PrivateKey = <your client private key>
    Address = 10.0.0.2/32
    DNS = 8.8.8.8

    [Peer]
    PublicKey = <server public key from install script>
    Endpoint = 64.237.48.180:51820
    AllowedIPs = 0.0.0.0/0, ::/0
    PersistentKeepalive = 25
    ```
  - (Optional) Rename the file:  
    `mv config/wg0-client.conf.sample config/wg0-client.conf`
- **Add the Client as a Peer on the Server:**
  - On the server, edit `/etc/wireguard/wg0.conf` to add:
    ```ini
    [Peer]
    PublicKey = <contents of client_public.key>
    AllowedIPs = 10.0.0.2/32
    ```
  - Restart WireGuard:
    - `wg-quick down wg0`
    - `wg-quick up wg0`
- **Install the WireGuard Client on Your Device:**
  - Download the official WireGuard client for macOS from [WireGuard’s website](https://www.wireguard.com/install/) or via the App Store.
  - Import your configuration file (`wg0-client.conf`) into the WireGuard app.
  - Activate the VPN tunnel.

## 6. Testing
- **Ping Test:**
  - Command: `ping 8.8.8.8` (Expect replies with low latency)
- **Traceroute Test:**
  - Command: `traceroute 8.8.8.8` (First hop should be the VPN server, e.g., 10.0.0.1)
- **Public IP Verification:**
  - Command: `curl https://api.ipify.org` (Should return 64.237.48.180)

## 7. Screenshots
- Place screenshots in the `screenshots/` folder:
  - `server_config.png` – Server configuration and NAT setup.
  - `client_connection.png` – Client VPN connection status.

## 8. Troubleshooting
- **DNS Issues:**
  - Ensure the client config specifies `DNS = 8.8.8.8` and adjust system DNS if needed.
- **Routing Issues:**
  - Check the routing table with: `netstat -rn | grep default`
  - Confirm that the default route is via the VPN interface (e.g., `utunX`).

## 9. License
- This project is licensed under the MIT License. See the LICENSE file for details.

## 10. Acknowledgments
- Thanks to [WireGuard](https://www.wireguard.com/) for the VPN software.
- Thanks to Vultr for cloud hosting services.
- Acknowledgment to various online resources and tutorials that assisted in the setup.
