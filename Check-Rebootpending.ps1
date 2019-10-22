# Check-Rebootpending.ps1  => False / True
(Invoke-WmiMethod -Namespace root\ccm\clientsdk -Class CCM_ClientUtilities -Name DetermineIfRebootPending).RebootPending