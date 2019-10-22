# Disable-ISMServ-StartupType.ps1

get-service | Where {$_.Name -like "*ISMServ*"} | select -property name,starttype
# Set-Service -Name ISMServ -StartupType Disabled
# Set-Service -Name ISMServ -StartupType Manual