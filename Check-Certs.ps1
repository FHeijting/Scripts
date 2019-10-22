#Change to the location of the personal certificates
#Set-Location Cert:\CurrentUser\My
 
#Change to the location of the local machine certificates
#Set-Location Cert:\LocalMachine\My
 
#Get the installed certificates in that location
#Get-ChildItem | Format-Table Subject, FriendlyName, Thumbprint -AutoSize
 
#Get the installed certificates from a remote machine
$Srv = @(Get-ADComputer -Filter 'operatingsystem -like "*Windows Server*"' -Properties operatingsystem | Select-Object name, operatingsystem)
# $Certs = Invoke-Command -Computername $Srv -Scriptblock {Get-ChildItem "Cert:\LocalMachine\My"}
Invoke-Command -Computername $Srv.name -Scriptblock {Get-ChildItem -path Cert:\LocalMachine\My -recurse -expiringindays 60 } -ErrorAction SilentlyContinue| Select-Object -Property PSComputerName,Issuer,FriendlyName,NotAfter,ThumbPrint,EnhancedKeyUsageList | Format-Table -AutoSize



# Invoke-Command -Computername $Srv -Scriptblock { Get-ChildItem cert:\ -Recurse | Where-Object {$_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and $_.NotAfter -gt (Get-Date)} | Select-Object -Property FriendlyName,NotAfter,ThumbPrint | ConvertTo-Html | Set-Content C:\Temp\ExpiredCerts.htm }