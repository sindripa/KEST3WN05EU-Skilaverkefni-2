$publicAdapter = "Ethernet0"
$privateAdapter = "Ethernet1"

$privateAdapterIndex = (Get-NetAdapter -Name $privateAdapter).ifIndex
$publicAdapterIndex = (Get-NetAdapter -Name $publicAdapter).ifIndex

Rename-Computer -NewName "DC1"

Rename-NetAdapter -Name $publicAdapter -NewName "Public"
Rename-NetAdapter -Name $privateAdapter -NewName "Private"


New-NetIPAddress -InterfaceIndex $privateAdapterIndex -IPAddress 10.10.0.110 -PrefixLength 28
New-NetIPAddress -InterfaceIndex $privateAdapterIndex -IPAddress 2001:face:008b:2a02:ffff:ffff:ffff:ffff


Set-DnsClientServerAddress -InterfaceIndex $privateAdapterIndex -ServerAddresses 10.10.0.110


Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools

Restart-Computer