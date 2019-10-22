Function Get-SystemInfo
<#
.SYNOPSIS
Get Complete details of any server Local or remote
.DESCRIPTION
This function uses WMI class to connect to remote machine and get all related details
.PARAMETER COMPUTERNAMES
Just Pass computer name as Its parameter
.EXAMPLE 
Get-SystemInfo
.EXAMPLE 
Get-SystemInfo -ComputerName HQSPDBSP01
.NOTES
To get help:
Get-Help Get-SystemInfo
.LINK
http://sqlpowershell.wordpress.com
#>

{
param(
    [Parameter(Mandatory=$true)] $ComputerName,
    [switch] $IgnorePing
     )


$computer = $ComputerName

# Declare main data hash to be populated later
$data = @{}

$data.' ComputerName'=$computer

# Try an ICMP ping the only way Powershell knows how...
$ping = Test-Connection -quiet -count 1 $computer
$Ping = $(if ($ping) { 'Yes' } else { 'No' })

# Do a DNS lookup with a .NET class method. Suppress error messages.
$ErrorActionPreference = 'SilentlyContinue'
if ( $ips = [System.Net.Dns]::GetHostAddresses($computer) | foreach { $_.IPAddressToString } ) {
    
    $data.'IP Address(es) from DNS' = ($ips -join ', ')
    
}

else {
    
    $data.'IP Address from DNS' = 'Could not resolve'
    
}
# Make errors visible again
$ErrorActionPreference = 'Continue'

# We'll assume no ping reply means it's dead. Try this anyway if -IgnorePing is specified
if ($ping -or $ignorePing) {
    
    $data.'WMI Data Collection Attempt' = 'Yes (ping reply or -IgnorePing)'
    
    # Get various info from the ComputerSystem WMI class
    if ($wmi = Get-WmiObject -Computer $computer -Class Win32_ComputerSystem -ErrorAction SilentlyContinue) {
        
        $data.'Computer Hardware Manufacturer' = $wmi.Manufacturer
        $data.'Computer Hardware Model'        = $wmi.Model
        $data.'Memory Physical in MB'          = ($wmi.TotalPhysicalMemory/1MB).ToString('N')
        $data.'Logged On User'                 = $wmi.Username
        
    }
    
    $wmi = $null
    
    # Get the free/total disk space from local disks (DriveType 3)
    if ($wmi = Get-WmiObject -Computer $computer -Class Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction SilentlyContinue) {
        
        $wmi | Select 'DeviceID', 'Size', 'FreeSpace' | Foreach {
            
            $data."Local disk $($_.DeviceID)" = ('' + ($_.FreeSpace/1MB).ToString('N') + ' MB free of ' + ($_.Size/1MB).ToString('N') + ' MB total space with ' + ($_.Size/1MB - $_.FreeSpace/1MB).ToString('N') +' MB Used Space')
            
            
        }
        
    }
    
    $wmi = $null
    
    # Get IP addresses from all local network adapters through WMI
    if ($wmi = Get-WmiObject -Computer $computer -Class Win32_NetworkAdapterConfiguration -ErrorAction SilentlyContinue) {
        
        $Ips = @{}
        
        $wmi | Where { $_.IPAddress -match '\S+' } | Foreach { $Ips.$($_.IPAddress -join ', ') = $_.MACAddress }
        
        $counter = 0
        $Ips.GetEnumerator() | Foreach {
            
            $counter++; $data."IP Address $counter" = '' + $_.Name + ' (MAC: ' + $_.Value + ')'
            
        }
        
    }
    
    $wmi = $null
    
    # Get CPU information with WMI
    if ($wmi = Get-WmiObject -Computer $computer -Class Win32_Processor -ErrorAction SilentlyContinue) {
        
        $wmi | Foreach {
            
            $maxClockSpeed     =  $_.MaxClockSpeed
            $numberOfCores     += $_.NumberOfCores
            $description       =  $_.Description
            $numberOfLogProc   += $_.NumberOfLogicalProcessors
            $socketDesignation =  $_.SocketDesignation
            $status            =  $_.Status
            $manufacturer      =  $_.Manufacturer
            $name              =  $_.Name
            
        }
        
        $data.'CPU Clock Speed'        = $maxClockSpeed
        $data.'CPU Cores'              = $numberOfCores
        $data.'CPU Description'        = $description
        $data.'CPU Logical Processors' = $numberOfLogProc
        $data.'CPU Socket'             = $socketDesignation
        $data.'CPU Status'             = $status
        $data.'CPU Manufacturer'       = $manufacturer
        $data.'CPU Name'               = $name -replace '\s+', ' '
        
    }
    
    $wmi = $null
    
    # Get BIOS info from WMI
    if ($wmi = Get-WmiObject -Computer $computer -Class Win32_Bios -ErrorAction SilentlyContinue) {
        
        $data.'BIOS Manufacturer' = $wmi.Manufacturer
        $data.'BIOS Name'         = $wmi.Name
        $data.'BIOS Version'      = $wmi.Version
        
    }
    
    $wmi = $null
    
    # Get operating system info from WMI
    if ($wmi = Get-WmiObject -Computer $computer -Class Win32_OperatingSystem -ErrorAction SilentlyContinue) {
        
        $data.'OS Boot Time'     = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
        $data.'OS System Drive'  = $wmi.SystemDrive
        $data.'OS System Device' = $wmi.SystemDevice
        $data.'OS Language     ' = $wmi.OSLanguage
        $data.'OS Version'       = $wmi.Version
        $data.'OS Windows dir'   = $wmi.WindowsDirectory
        $data.'OS Name'          = $wmi.Caption
        $data.'OS Install Date'  = $wmi.ConvertToDateTime($wmi.InstallDate)
        $data.'OS Service Pack'  = [string]$wmi.ServicePackMajorVersion + '.' + $wmi.ServicePackMinorVersion
        
    }
    
    # Scan for open ports
    $ports = @{ 
                'File shares/RPC' = '139' ;
                'File shares'     = '445' ;
                'RDP'             = '3389';
                #'Zenworks'        = '1761';
              }
    
    foreach ($service in $ports.Keys) {
        
        $socket = New-Object Net.Sockets.TcpClient
        
        # Suppress error messages
        $ErrorActionPreference = 'SilentlyContinue'
        
        # Try to connect
        $socket.Connect($computer, $ports.$service)
        
        # Make error messages visible again
        $ErrorActionPreference = 'Continue'
        
        if ($socket.Connected) {
            
            $data."Port $($ports.$service) ($service)" = 'Open'
            $socket.Close()
            
        }
        
        else {
            
            $data."Port $($ports.$service) ($service)" = 'Closed or filtered'
            
        }
        
        $socket = $null
        
    }
    
}

else {
    
    $data.'WMI Data Collected' = 'No (no ping reply and -IgnorePing not specified)'
    
}

$wmi = $null


if ($wmi = Get-WmiObject -Class Win32_OperatingSystem -computername $Computer -ErrorAction SilentlyContinue| Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory,TotalVirtualMemorySize,FreeVirtualMemory,FreeSpaceInPagingFiles,NumberofProcesses,NumberOfUsers ) {
        
        $wmi | Foreach {
            
            $TotalRAM     =  $_.TotalVisibleMemorySize/1MB
            $FreeRAM     = $_.FreePhysicalMemory/1MB
            $UsedRAM       =  $_.TotalVisibleMemorySize/1MB - $_.FreePhysicalMemory/1MB
            $TotalRAM = [Math]::Round($TotalRAM, 2)
            $FreeRAM = [Math]::Round($FreeRAM, 2)
            $UsedRAM = [Math]::Round($UsedRAM, 2)
            $RAMPercentFree = ($FreeRAM / $TotalRAM) * 100
            $RAMPercentFree = [Math]::Round($RAMPercentFree, 2)
            $TotalVirtualMemorySize  = [Math]::Round($_.TotalVirtualMemorySize/1MB, 3)
            $FreeVirtualMemory =  [Math]::Round($_.FreeVirtualMemory/1MB, 3)
            $FreeSpaceInPagingFiles            =  [Math]::Round($_.FreeSpaceInPagingFiles/1MB, 3)
            $NumberofProcesses      =  $_.NumberofProcesses
            $NumberOfUsers              =  $_.NumberOfUsers
            
        }
        $data.'Memory - Total RAM GB '  = $TotalRAM
        $data.'Memory - RAM Free GB'    = $FreeRAM
        $data.'Memory - RAM Used GB'    = $UsedRAM
        $data.'Memory - Percentage Free'= $RAMPercentFree
        $data.'Memory - TotalVirtualMemorySize' = $TotalVirtualMemorySize
        $data.'Memory - FreeVirtualMemory' = $FreeVirtualMemory
        $data.'Memory - FreeSpaceInPagingFiles' = $FreeSpaceInPagingFiles
        $data.'NumberofProcesses'= $NumberofProcesses
        $data.'NumberOfUsers'    = $NumberOfUsers -replace '\s+', ' '
        
    }

# Output data
"#"*80
"OS Complete Information"
"Generated $(get-date)"
"Generated from $(gc env:computername)"
"#"*80



$data.GetEnumerator() | Sort-Object 'Name' | Format-Table -AutoSize
$data.GetEnumerator() | Sort-Object 'Name' | Out-GridView -Title "$computer Information"
}
