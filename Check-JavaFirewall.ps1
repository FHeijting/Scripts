
Function Get-FireWallRule {
  Param ($Name, $Direction, $Enabled, $Protocol, $Profile, $Action, $Grouping, $ApplicationName)

    $Rules=(New-object –comObject HNetCfg.FwPolicy2).rules
    If ($Name)      {$rules= $rules | where-object {$_.name     –like $Name}}
    If ($Direction) {$rules= $rules | where-object {$_.direction  –eq $Direction}}
    If ($Enabled)   {$rules= $rules | where-object {$_.Enabled    –eq $Enabled}}
    If ($Protocol)  {$rules= $rules | where-object {$_.protocol  -eq  $Protocol}}
    If ($Profile)   {$rules= $rules | where-object {$_.Profiles -bAND $Profile}}
    If ($Action)    {$rules= $rules | where-object {$_.Action     -eq $Action}}
    If ($Grouping)  {$rules= $rules | where-object {$_.Grouping -Like $Grouping}}
    If ($ApplicationName)  {$rules= $rules | where-object {$_.ApplicationName -Like $ApplicationName}}
  $rules
}

$RetVal = $True
if (!(Get-firewallRule -ApplicationName 'Java.exe' )) {
    $RetVal = $False
}
if (!(Get-firewallRule -ApplicationName 'Javaw.exe' )) {
    $RetVal = $False
}

Return $RetVal
