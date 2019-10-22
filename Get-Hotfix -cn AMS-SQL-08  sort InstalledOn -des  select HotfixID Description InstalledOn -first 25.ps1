Get-Hotfix -cn ACC-SQL-08 | sort InstalledOn -des  | select HotfixID, Description, InstalledOn -first 100
Get-Hotfix -cn ACC-SQL-09 | sort InstalledOn -des  | select HotfixID, Description, InstalledOn -first 100
Get-Hotfix -cn ACC-SQL-10 | sort InstalledOn -des  | select HotfixID, Description, InstalledOn -first 100

Get-Hotfix -cn Localhost | sort InstalledOn -des  | select HotfixID, Description, InstalledOn -first 15

Write LastbootUpTime
# (Get-WMIObject Win32_OperatingSystem).LastBootUpTime
$Booted = (Get-WmiObject Win32_OperatingSystem).LastBootUpTime
	[Management.ManagementDateTimeConverter]::ToDateTime($Booted)

Get-WmiObject -Class Win32_Operatingsystem
(gwmi win32_operatingsystem).caption