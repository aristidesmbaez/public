#!/bin/bash
# Applies VPN Kill Switch to MacOS firewall
#VARIABLES
VPNRULES=/private/etc/pf.anchors/vpnkillswitch.pf.rules
IPWHITELIST=/private/etc/pf.anchors/vpn.list

#Checks for firewall policies in pf.conf and adds them if they do not exist.
if grep -q "vpnkillswitch.pf" /private/etc/pf.conf; then
    echo "Configuration already in pf.conf, no changes made to pf.conf"
else
    echo "Updating pf.conf"
    # Backup pf configuration
    mkdir -p /Library/vpnkillswitch/backup
    cp /private/etc/pf.conf /Library/vpnkillswitch/backup/pf.conf.backup
    cp -r /private/etc/pf.anchors /Library/vpnkillswitch/backup
    #Update PF conf to add killswitch
    echo -e "anchor \"vpnkillswitch.pf\"\nload anchor \"vpnkillswitch.pf\" from \"/etc/pf.anchors/vpnkillswitch.pf.rules\"" >> /private/etc/pf.conf
fi

#Checks for vpnkillswitch.pfrules and creates it if it does not exist
if [ -f "$VPNRULES" ]; then
  echo "vpnkillswitch.pf.rules already exists, skipping creation"
else
  echo "Creating vpnkillswitch.pf.rules"
cat > $VPNRULES << EOF
# Options
set block-policy drop
set fingerprints "/etc/pf.os"
set ruleset-optimization basic
set skip on lo0

# Interfaces
vpn_intf = "{utun0 utun1 utun2 utun3 utun4 utun5 utun6 utun7 utun8 utun9 utun10}"

# Ports
allowed_vpn_ports = "{1:65535}"

# Table with allowed IPs
table <allowed_vpn_ips> persist file "/etc/pf.anchors/vpn.list"

# Block all outgoing packets
block out all

# Allow outgoing packets to specified IPs only
pass out proto icmp from any to <allowed_vpn_ips>
pass out proto {tcp udp} from any to <allowed_vpn_ips>

# Allow DNS
pass out proto tcp from any to any port 53
pass out proto udp from any to any port 53

# Allow traffic for VPN interfaces
pass out on \$vpn_intf all
EOF
fi

if [ -f "$IPWHITELIST" ]; then
  echo "vpn.list already exists, skipping creation"
else
  echo "Creating IP whitelist file"
cat > $IPWHITELIST << EOF
172.30.4.254
13.255.221.2
52.85.61.10
54.185.180.163
3.82.0.92/32
EOF
fi
#Restarting Firewall
echo "Restarting firewall and enabling vpn killswitch policy"
    pfctl -F all -f /etc/pf.conf &> /dev/null

exit 0
