# Install Managed Service Accounts on SQL Servers.ps1
# Run on the local machine!
$Computername = (Get-WMIObject Win32_ComputerSystem | Select-Object -ExpandProperty name)
$Computername
$Domain = (Get-WMIObject Win32_ComputerSystem | Select-Object -ExpandProperty Domain)
$Domain
# Install Active Directory module for Windows Powershell 
# Add Roles and Features Wizard
# RSAT Remote Server Administrator Tools
# AD DS and AD LDS Toools
Enable-WindowsOptionalFeature -FeatureName ActiveDirectory-Powershell -Online -All
# Addd machine to AD group " SQLServers! "

======
# Add-Computer_2_SQLServer_Group.ps1
Import-Module ActiveDirectory

$Computername = (Get-WMIObject Win32_ComputerSystem | Select-Object -ExpandProperty name)
$Computername

## $RemoteComputer = get-content C:\Users\BPATFR\_Scripts\computernames.txt
## $RemoteComputer

$_Comp = Get-ADComputer -Identity $Computername
$_Comp
ADD-ADGroupMember -Identity "CN=SQLServers,OU=2016,OU=FvLServers,DC=ot,DC=otam,DC=fvl" –Members $_Comp

# Restart-Computer -ComputerName $Computername

# ====== 2e Part
# Install Managed Service Accounts on SQL Servers.ps1
# Rebooted ! 
# Run Script as below!
# Delete SPN!
# SetSPN -d "MSSQLSvc/SQLTWA08.ot.otam.fvl:1433" "OT\SASQLTWA08SQLU01"
# Create / SETSPN!  
# SetSPN -s "MSSQLSvc/regtwa27.ot.otam.fvl:1433" "ot\gMSAsqluservice$" 

$Computername = (Get-WMIObject Win32_ComputerSystem | Select-Object -ExpandProperty name)
$Computername
$Domain = (Get-WMIObject Win32_ComputerSystem | Select-Object -ExpandProperty Domain)
$Domain

Import-Module ActiveDirectory

Install-ADServiceAccount -Identity gMSAsqluservice$ -Auth Negotiate 
Install-ADServiceAccount -Identity gMSAagntservice$
Install-ADServiceAccount -Identity gMSAssisservice$
Install-ADServiceAccount -Identity gMSAssasservice$
Install-ADServiceAccount -Identity gMSAssrsservice$

Test-ADServiceAccount -Identity gMSAsqluservice$
Test-ADServiceAccount -Identity gMSAagntservice$
Test-ADServiceAccount -Identity gMSAssisservice$
Test-ADServiceAccount -Identity gMSAssasservice$
Test-ADServiceAccount -Identity gMSAssrsservice$

setspn -S MSSQLSvc/$Computername.$Domain:1433 $Domain\gMSAsqluservice$

setspn -L gMSAsqluservice$
Test-NetConnection -ComputerName $Computername.$Domain -port  1433
# ======

