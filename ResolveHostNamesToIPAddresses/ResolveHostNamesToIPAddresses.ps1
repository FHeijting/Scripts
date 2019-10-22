# ResolveHostNamesToIPAddresses.ps1
#

function Get-HostToIP($hostname) {  
    Write $hostname  
    $result = [system.Net.Dns]::GetHostByName($hostname)    
    $result.AddressList | ForEach-Object {$_.IPAddressToString }
}

Get-Content "C:\Users\BPATFR\_Scripts\PS1\ResolveHostNamesToIPAddresses\Servers-Hostnames.txt" | ForEach-Object {(Get-HostToIP($_)) + ($_).HostName >> C:\Users\BPATFR\_Scripts\PS1\ResolveHostNamesToIPAddresses\IP-Server-Addresses.txt}
