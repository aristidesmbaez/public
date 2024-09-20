#! /bin/bash

USER=$(id -u -n)
machinename=$(hostname)
if grep "$machinename" /usr/local/.vdi/machines
then
    echo "Script already run exiting"
else
    echo "Install Device Posture Cert"
    cp /usr/local/.vdi/local-ca.crt /usr/local/share/ca-certificates
    update-ca-certificates
    echo "Install Connect Wise"
    dpkg -i /usr/local/.vdi/ConnectWiseControl.ClientSetup.deb
    echo "Register Nessus"
    /opt/nessus_agent/sbin/nessuscli agent link --key=5debefaf3d5bedd809ea326ac
    echo "Start S1"
    /opt/sentinelone/bin/sentinelctl control start
    echo "$machinename" >> /usr/local/.vdi/machines

fi
exit 0
