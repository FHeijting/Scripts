# Check-LastRebootTime.ps1

Get-CimInstance -ClassName win32_operatingsystem | select csname, lastbootuptime
