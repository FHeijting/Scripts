# TriggerUpdates.ps1
# Version All TriggerUpdates.ps1 v1.0
#
# $Servers = Get-Content "C:\users\$env:username\desktop\servers.txt"
$Servers = Get-Content "C:\users\$env:username\_Scripts\PS1\Patching\TriggerUpdates-ServerList.txt"
$Array = @()

Clear-Host

Foreach($Server in $Servers)
{

$Server = $Server.trim()

      Write-Host "`nStatus $Server" -BackgroundColor DarkCyan

      $Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Server | Where-Object { $_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*"})
      Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Application) -Namespace root\ccm\clientsdk -ComputerName $Server
}

If($Array)
{
      #$Array | Sort-Object "Online?"

      #$Array | Out-GridView

      #$Array | Out-File -Path "C:\users\$env:username\_Scripts\PS1\Patching\TriggerUpdates-Result.txt" -NoTypeInformation -Force
}
