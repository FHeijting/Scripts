# Get-Hotfix -cn Localhost.ps1

Get-Hotfix -cn Localhost | sort InstalledOn -des  | select HotfixID, Description, InstalledOn -first 10

