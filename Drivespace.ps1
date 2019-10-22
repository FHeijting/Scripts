$report = $null
$LogFile = ".\Drivespace.log"
$Export = ".\Log\{0:yyyy-MM-dd_HHmmss}.log"   -f (Get-Date)

if(test-path $Export) {
    Remove-Item $Export
}

Start-Transcript $LogFile

#$ADCompList = Get-ADComputer -Filter {(OperatingSystemVersion -like "6.*") -and (OperatingSystem -like "*Windows Server*")} -Properties OperatingSystem,OperatingSystemVersion | Sort-Object -Property OperatingSystemVersion,Name
$report = @()
$ADCompList = Get-ADComputer -Filter {OperatingSystem -like "*Windows Server*"} -Properties OperatingSystem,OperatingSystemVersion | Sort-Object -Property Name
$report += "Drivespace C:"
$report += ""
$report += "Name`tDrive`tSize (Gb)`tFreespace (Gb)`tPercentage (% free)"

ForEach ($ADComputer in $ADCompList ) {
    if (Test-Connection -ComputerName $ADComputer.Name -Count 1 -ErrorAction SilentlyContinue) {
      write $ADComputer.Name " Drive C:"
      if($disk = Get-WmiObject Win32_LogicalDisk -ComputerName $AdComputer.Name | Where-Object {$_.DeviceID -eq 'C:' -and $_.DriveType -eq 3} | Select-Object DeviceID,Size,FreeSpace) {
            if(([Math]::Round(($disk.FreeSpace / $disk.size)*100)) -lt 10) {
                $report += $ADComputer.Name + "`t" + $disk.DeviceID + "`t" + [Math]::Round($disk.size / 1Gb, 2) + "`t" + [Math]::Round($disk.FreeSpace / 1Gb) + "`t" + [Math]::Round(($disk.FreeSpace / $disk.size)*100) + "%"
            }
      }
    } else {
        write "$($ADComputer.Name) not reachable"
    }
}


$report += ""
$report += "Drivespace D:"
$report += ""
$report += "Name`tDrive`tSize (Gb)`tFreespace (Gb)`tPercentage (% free)"

ForEach ($ADComputer in $ADCompList ) {
    if (Test-Connection -ComputerName $ADComputer.Name -Count 1 -ErrorAction SilentlyContinue) {
      write $ADComputer.Name " Drive D:"
      if($disk = Get-WmiObject Win32_LogicalDisk -ComputerName $AdComputer.Name | Where-Object {$_.DeviceID -eq 'D:' -and $_.DriveType -eq 3} | Select-Object DeviceID,Size,FreeSpace) {
            if(([Math]::Round(($disk.FreeSpace / $disk.size)*100)) -lt 10) {
                $report += $ADComputer.Name + "`t" + $disk.DeviceID + "`t" + [Math]::Round($disk.size / 1Gb, 2) + "`t" + [Math]::Round($disk.FreeSpace / 1Gb) + "`t" + [Math]::Round(($disk.FreeSpace / $disk.size)*100) + "%"
            }
      }
    } else {
        write "$($ADComputer.Name) not reachable"
    }
}

$report | Out-File $Export
#$report | Export-CSV $ExportCSV -Delimiter ";" -NoTypeInformation
Stop-Transcript
