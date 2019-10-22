
Write-Host "Enable Remote Desktop..."


Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0

if ((Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -ErrorAction SilentlyContinue) -eq $Null) {
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -Value 0 -PropertyType DWord
} else {
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -Value 0
}

Write-Host "Opening Firewall ports for Remote Desktop..."
if (netsh advfirewall firewall show rule all | select-string "Extern Bureaublad") {
  netsh advfirewall firewall set rule group="Extern Bureaublad" new enable=yes 
}
if (netsh advfirewall firewall show rule all | select-string "Remote Desktop") {
  netsh advfirewall firewall set rule group="Remote Desktop"    new enable=yes 
}


Write-Host "Enable PowerShell Remoting..."
Enable-PSRemoting -Force

Return 0
