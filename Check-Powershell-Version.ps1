# Check-Powershell-Version.ps1
Get-Host | Select-Object Version
Get-ExecutionPolicy
Get-Service winrm
Start-Service winrm
Test-WSMan -Computername Localhost -Authentication default
winrm e winrm/config/listener
Winrm id
winrm get winrm/config
winrm get wmicimv2/Win32_Service?Name=WinRM


# Powershell
# Get-ExecutionPolicy
# Set-ExecutionPolicy RemoteSigned -Force

# Enable-PSRemoting

# WinRM
# Get-Service winrm
# Start-Service winrm
# Set-WSManQuickConfig
# Test-WSMan -Computername Localhost

# Set WinRM using Basic authentication:
# winrm set winrm/config/client/auth '@{Basic="True"}'

# Locate listeners and addresses
# winrm e winrm/config/listener
# Check state of configuration settings:
# winrm get winrm/config
# Check the state of WinRM service:
# winrm get wmicimv2/Win32_Service?Name=WinRM
# Remote Ping WinRM
# Winrm id –r:machinename
# Check remote configuration settings:
# winrm get winrm/config -r:machinename 
# Check the state of WinRM service
# winrm get wmicimv2/Win32_Service?Name=WinRM -r:machinename
