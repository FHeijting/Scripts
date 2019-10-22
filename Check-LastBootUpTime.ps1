# CheckLastBootTime.ps1
# Get-CimInstance -ClassName win32_operatingsystem | select csname, lastbootuptime

 [CmdletBinding()]
     Param(
      [Parameter(Mandatory=$True)]
      [String]$Identity      
    )
$Computername = $Identity

Enter-PSSession -ComputerName $Computername
# Start-Sleep -seconds 15
# Wait-Process 
# $COMMAND = Get-CimInstance -ClassName win32_operatingsystem | select csname, lastbootuptime
# $COMMAND
# Exit-PSSession

# Invoke-Command -ComputerName $Computername -ScriptBlock { $COMMAND } -credential FVLPROD\BPATFR
# Check-Rebootpending.ps1  => False / True
# (Invoke-WmiMethod -Namespace root\ccm\clientsdk -Class CCM_ClientUtilities -Name DetermineIfRebootPending).RebootPending
