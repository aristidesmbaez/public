<# 
    .DESCRIPTION 
        Basic Script to Deploy new Active Directory on Windows Server for use with AWS Connector
#> 

#Variables
$DomainName = "Lan.company.com"
$NetBios = "LAN"

#Install AD DS Role
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

#Import Active Directory Deployment Module
Import-Module ADDSDeployment

#Setup AD
Write-Host "Installing AD Forest, machine will reboot when complete"
Install-ADDSForest -DomainName "$DomainName" -DomainNetBiosName "$NetBios" -InstallDns -Force
