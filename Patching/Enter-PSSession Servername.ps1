 [CmdletBinding()]
     Param(
      [Parameter(Mandatory=$True)]
      [String]$Identity      
    )
$Computername = $Identity

Enter-PSSession -ComputerName $Computername