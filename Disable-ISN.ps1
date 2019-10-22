# Disable-ISN.ps1
# A simple script to disconnect the ISN adapter for VMWare guests
# Takes name of VM as parameter
# Date: 2018-09-19
# Author: Suraj Kalloe

# set parameters
Param(
    [Parameter(mandatory)]
    [string]$VM
)

# declare variables
$vmwareServers="vispwa12.fvlprod.fvl","vispwa13.fvlprod.fvl"
$nicName="vlan_OTAM-ISN_102"

# Import VMWare module
Import-Module VMware.PowerCLI

# Connect to VMWare server(s)
Connect-VIServer -Server $vmwareServers|Out-Null

# Get adapter for VM and set connected + startconnected to false
Get-NetworkAdapter -VM $VM |where { $_.NetworkName -eq $nicName}|
Set-NetworkAdapter -Connected:$false -StartConnected:$false -Confirm:$false|Out-Null

# Output message
Write-Host "Successfully disconnected ISN adapter for $VM"
Get-NetworkAdapter -VM $VM|where { $_.NetworkName -eq $nicName}|select NetworkName,ConnectionState

Disconnect-VIServer -Server $vmwareServers