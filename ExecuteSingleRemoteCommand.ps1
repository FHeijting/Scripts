# Execute a Single Remote Command
# Invoke-Command -ComputerName 10.0.0.22 -ScriptBlock { Get-ChildItem C:\ } -credential Doamin\username
 [CmdletBinding()]
     Param(
      [Parameter(Mandatory=$True)]
      [String]$Identity      
    )
$Computername = $Identity
# Check Last boot time
$COMMAND = Get-CimInstance -ClassName win32_operatingsystem | select csname, lastbootuptime
Invoke-Command -ComputerName $Computername -ScriptBlock { $COMMAND } -credential FVLPROD\BPATFR
# Display output
$COMMAND

Exit-PSSession

# Get-PSSession | Format-Table -Property ComputerName, InstanceID
# $s = Get-PSSession -InstanceID a786be29-a6bb-40da-80fb-782c67f7db0f
# Remove-PSSession -Session $s

