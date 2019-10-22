# Run-AllSystemReboot.ps1
# Version Run-AllSystemReboot.ps1 v1.0
#
$Servers = Get-Content "C:\users\$env:username\_Scripts\PS1\Patching\RebootServers.txt"
# $Servers
$Array = @()

Clear-Host

Foreach($Server in $Servers)
{

$Server = $Server.trim()

      Write-Host "`nReboot $Server" -BackgroundColor DarkCyan

$j = restart-computer -ComputerName $Server -force
}
