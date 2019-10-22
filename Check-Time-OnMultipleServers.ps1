# Check-Time-OnMultipleServers.ps1

$servers = Get-Content -Path “C:\Users\BPATFR\_Scripts\PS1\computernames.csv” 
ForEach ($server in $servers) {
    $time = ([WMI]'').ConvertToDateTime((gwmi win32_operatingsystem -computername $server).LocalDateTime)
    $server + '  ' + $time
}
