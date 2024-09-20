#!/bin/bash
# Disables VPN Kill Switch

#check for backups
BACKUPDIR=/Library/vpnkillswitch/backup/pf.anchors/com.apple
if [ -f "$BACKUPDIR" ]; then
  echo "Firewall config backups exists, Restoring files"
  cp /Library/vpnkillswitch/backup/pf.conf.backup /private/etc/pf.conf
  rm -r /private/etc/pf.anchors
  cp -r /Library/vpnkillswitch/backup/pf.anchors /private/etc
  echo "Restarting firewall and disabling vpn killswitch policy"
  pfctl -F all -f /etc/pf.conf &> /dev/null
else
  echo "Firewall config backups don't exist, no changes made, exiting"
fi
