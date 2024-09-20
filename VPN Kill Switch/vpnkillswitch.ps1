$ips = @("172.30.4.254")
Remove-NetFirewallRule -AssociatedNetFirewallProfile Public
Set-NetFirewallProfile –Name Public –DefaultOutboundAction Block
New-NetFirewallRule -DisplayName "Allow AWS and Okta TCP Public" -Direction Outbound -Protocol TCP -RemoteAddress $ips -Profile Public -Action Allow
New-NetFirewallRule -DisplayName "Allow AWS and Okta UDP Public" -Direction Outbound -Protocol UDP -RemoteAddress $ips -Profile Public -Action Allow
New-NetFirewallRule -DisplayName "Allow DNS TCP" -Direction Outbound -Protocol TCP -LocalPort 53 -Profile Public -Action Allow
New-NetFirewallRule -DisplayName "Allow DNS UDP" -Direction Outbound -Protocol UDP -LocalPort 53 -Profile Public -Action Allow
New-NetFirewallRule -DisplayName "Allow DHCP UDP" -Direction Outbound -Protocol UDP -LocalPort @('67','68') -Profile Public -Action Allow
