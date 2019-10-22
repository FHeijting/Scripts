# Check-DotNet-Version.ps1

$dotNetV = (dir $env:windir\Microsoft.NET\Framework\v* | sort lastwritetime -desc | select -First 1) ; $dotNetV.Name

# Check-DotNetVersion.ps1
# minimum-required .NET Framework version!
#
# https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
# releaseKey >= 528040
# 4.8 or later
# releaseKey >= 461808
# 4.7.2
# releaseKey >= 461308
# 4.7.1
# releaseKey >= 460798
# 4.7
# releaseKey >= 394802
# 4.6.2
# releaseKey >= 394254
# 4.6.1      
# releaseKey >= 393295
# 4.6      
# releaseKey >= 379893
# 4.5.2      
# releaseKey >= 378675
# 4.5.1      
# releaseKey >= 378389
# 4.5  

Write ' # Minimum .NET Framework Version 4.5.1 ' 
# PowerShell 5
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' |  Get-ItemPropertyValue -Name Release | Foreach-Object { $_ -ge 394802 }


# PowerShell 4
(Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 394802