
Install-WindowsFeature dhcp -IncludeManagementTools

Add-DhcpServerv4Scope -Name "Let's'a go" -StartRange 10.10.0.1 -EndRange 10.10.0.14 -SubnetMask 255.255.255.240
Add-DhcpServerv4ExclusionRange -StartRange 10.10.0.11 -EndRange 10.10.0.14 -ScopeId 10.10.0.0

Add-DhcpServerv6Scope -Name "Let's'a goV6" -Prefix 2001:face:8b:2a00::

Restart-Service Dhcpserver




$InternalIPNetwork = "10.10.0.0/24"

Install-WindowsFeature -name "NET-Framework-Features" –IncludeManagementTools
New-NetNat -Name "ClientNAT" -InternalIPInterfaceAddressPrefix $InternalIPNetwork


Install-WindowsFeature -name "WINS" –IncludeManagementTools



New-Item -Path "c:\" -Name EmplyeeShare -ItemType "directory"
New-Item -Path "c:\EmplyeeShare" -Name Tölvudeild -ItemType "directory"
New-Item -Path "c:\EmplyeeShare" -Name Rekstrardeild -ItemType "directory"
New-Item -Path "c:\EmplyeeShare" -Name Framkvæmdadeild -ItemType "directory"
New-Item -Path "c:\EmplyeeShare" -Name Framleiðsludeild -ItemType "directory"

New-Item -Path "c:\EmplyeeShare" -Name SharedShare  -ItemType "directory"
New-SmbShare -Path "c:\EmplyeeShare" -Name SharedShare -FullAccess everyone


New-SmbShare -Name SharedIT -Path "c:\EmplyeeShare\Tölvudeild"  -FullAccess sindri.local\administrator
New-SmbShare -Name SharedManagement -Path "c:\EmplyeeShare\Rekstrardeild"  -FullAccess sindri.local\administrator
New-SmbShare -Name SharedEngineering -Path "c:\EmplyeeShare\Framkvæmdadeild" -FullAccess sindri.local\administrator
New-SmbShare -Name SharedHarpa -Path "c:\EmplyeeShare\Framleiðsludeild"  -FullAccess sindri.local\administrator



$printDriverName =  "Microsoft Print To PDF"


Install-WindowsFeature Print-Services -IncludeManagementTools

Add-PrinterDriver -Name  $printDriverName

Add-PrinterPort -Name TölvudeildPrintPort -PrinterHostAddress 10.10.0.15
Add-Printer -Name TölvudeildPrinter -DriverName $printDriverName -PortName TölvudeildPrintPort

Add-PrinterPort -Name RekstrardeildPrintPort -PrinterHostAddress 10.10.0.16
Add-Printer -Name RekstrardeildPrinter -DriverName $printDriverName -PortName RekstrardeildPrintPort

Add-PrinterPort -Name FramkvæmdadeildPrintPort -PrinterHostAddress 10.10.0.17
Add-Printer -Name FramkvæmdadeildPrinter -DriverName $printDriverName -PortName FramkvæmdadeildPrintPort

Add-PrinterPort -Name FramleiðsludeildPrintPort -PrinterHostAddress 10.10.0.18
Add-Printer -Name FramleiðsludeildPrinter -DriverName $printDriverName -PortName FramleiðsludeildPrintPort

Add-PrinterPort -Name SharedPrintPort -PrinterHostAddress 10.10.0.19
Add-Printer -Name SharedPrinter -DriverName $printDriverName -PortName SharedPrintPort










$gpopath = "C:\GPOs"

class GPO {
    [string]$name
    [string]$id
    $path = $gpopath + "\" + $name

}


$employeeOU = "OU=company," + (Get-ADDomain).DistinguishedName

$GROUPS = @()
foreach($i in $env:GROUPS.Split(";")){$GROUPS += ,$i}

$groupsOUs = @()
foreach($i in $GROUPS){$groupsOUs += "OU=" + $i + "," + $employeeOU}

function linkSome ([GPO]$GPO, $groups){

    New-GPO -Name $GPO.name
    Import-GPO -Path $GPO.path -BackupId $GPO.id -TargetName $GPO.name

    foreach($group in $groups){
        New-GPLink -Name $GPO.name -Target $groupsOUs[$group]
        
        echo $GPO.name + "has been applied to " + $groupsOUs[$group] 
    }
}
function linkAll ([GPO]$GPO){

    New-GPO -Name $GPO.name
    Import-GPO -Path $GPO.path -BackupId $GPO.id -TargetName $GPO.name
    New-GPLink -Name $GPO.name -Target $employeeOU

    echo $GPO.name + "has been applied to all" 
    
}



foreach($GPO in (Get-ChildItem $gpopath).Name){
    if($GPO.Contains('&'))
    {
        $GPO1 = [GPO]::new()
        $GPO1.id = (Get-ChildItem "$gpopath\$GPO").Name
        $GPO1.name = $GPO

        $gprStr = $GPO.Split('&')[0]
        $grps = $gprStr.Split(' ')

        linkSome $GPO1 $grps

    }
    else
    {
        $GPO1 = [GPO]::new()
        $GPO1.id = (Get-ChildItem "$gpopath\$GPO").Name
        $GPO1.name = $GPO

        linkAll($GPO1)
    }
}