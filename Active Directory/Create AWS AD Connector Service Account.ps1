<# 
    .DESCRIPTION 
        Basic Script to Deploy Setup AWS AD Connector user account and group
#> 

#Variables
$AWSConnectUser = "AWS Connector"
$AWSGroupName = "AWS Connector Group"
$AWSGroupSAM = "AWSGroup"
$OrganizationalUnit = "DC=lan,DC=company,DC=com"

#Setup Service user account and groups

New-ADUser -Name "$AWSConnectUser" -Enabled $true
New-ADGroup -Name $AWSGroupName -SamAccountName $AWSGroupSAM -GroupCategory Security -GroupScope Global -DisplayName "AWS Service Group" -Path "CN=Users,DC=awsads,DC=axoni,DC=com" -Description "Members of this group are have delegated access to the domain"

#Setup AWS service group delegation access to ad
    
Set-Location AD:
$Group = Get-ADGroup -Identity $AWSGroupSAM
$GroupSID = [System.Security.Principal.SecurityIdentifier] $Group.SID
$ACL = Get-Acl -Path $OrganizationalUnit
    
$Identity = [System.Security.Principal.IdentityReference] $GroupSID
$ADRight = [System.DirectoryServices.ActiveDirectoryRights] "GenericAll"
$Type = [System.Security.AccessControl.AccessControlType] "Allow"
$InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
$Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity, $ADRight, $Type,  $InheritanceType)
   
$ACL.AddAccessRule($Rule)
Set-Acl -Path $OrganizationalUnit -AclObject $ACL

#Add AWS Service Account to Service Group
Add-ADGroupMember -Identity $AWSGroupSAM -Members $AWSConnectUser
