# Check-dotNetVersion.ps1

$Servers = Get-Content -Path 'C:\Users\BPATFR\_Scripts\PS1\dotNet-serverlist.txt'
cls
foreach ($server in $Servers)
{
$version = Invoke-Command -ComputerName $server -ScriptBlock {
      $dotNetV = (dir $env:windir\Microsoft.NET\Framework\v* | sort lastwritetime -desc | select -First 1) ; $dotNetV.Name 
}
Write-Output "$server is using .Net Framework version $version" 
}

# $Command = {dir $env:windir\Microsoft.NET\Framework\v* | sort lastwritetime -desc | select -First 1} 
# Get-WmiObject Win32_SoftwareElement | ? { $_.name -eq "system.net.dll_x86" }
# Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP'
# $InstallPath = (Get-Command java | Select-Object Definition) ; $InstallPath.Definition
# $Path = Invoke-Command -Computername $Server -ScriptBlock { $InstallPath = (Get-Command java | Select-Object Definition) ; $InstallPath.Definition}

