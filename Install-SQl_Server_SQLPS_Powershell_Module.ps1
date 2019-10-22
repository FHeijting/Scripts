# Install-SQl_Server_SQLPS_Powershell_Module.ps1
#
# https://sqlpadawan.com/2018/08/01/how-to-install-sql-server-sqlps-powershell-module/

# Microsoft® SQL Server® 2016 Feature Pack 
# https://www.microsoft.com/en-us/download/details.aspx?id=52676
# PRODFVL : \\NFCPCA01.FVLPROD.FVL\SoftwareRepository\Software\Microsoft\SQLServer\SQLPS
# AM /OT  : \\NFCACA01.AM.OTAM.FVL\SoftwareRepository\Software\Microsoft\SQLServer\SQLPS
# 1e Install : 2016 System CLR Types for Microsoft® SQL Server® => SQLSysClrTypes.msi to D-Drive
# 2e Install : 2016 SQL Server® Shared Management Objects => SharedManagementObjects.msi to D-Drive
# ================================================================
# 3e Install : 2016 PowerShell Extensions for Microsoft SQL Server => PowerShellTools.msi to D-Drive
# Install-Module -Name SQLServer -AllowClobber
# Open Powershell under Adminrights!
# D:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS
D:
cd "D:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS"
Import-Module -Name SQLPS
# Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned
#
# Check Environment path for SQLPS!
# To add locations to the PSModulePath variable
# https://docs.microsoft.com/en-us/powershell/developer/module/modifying-the-psmodulepath-installation-path
$env:PSModulePath = $env:PSModulePath + ";D:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS"
$env:PSModulePath
# ================================================================
# Set Temporary environment current session!
# $env:PSModulePath = $env:PSModulePath + ";c:\ModulePath"
# Set Persistent
# $CurrentValue = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
# $CurrentValue
# [Environment]::SetEnvironmentVariable("PSModulePath", $CurrentValue + ";D:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS", "Machine")
# 
# remove locations from the PSModulePath
# $env:PSModulePath = $env:PSModulePath -replace ";D:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS"
# ================================================================
# ================================================================
# 4e Install : SQLServer Powershell
# ! Install-Module -Name SQLServer -AllowClobber
# ! Save SQLServer module from other system where you van download! 
# ---------
# C:
# MD C:\SQLServer
# Save-Module -Name SQLServer -Path C:\SQLServer
# ! Copy SQLServer Folder to New system "C:\Program Files\WindowsPowerShell\Modules\SqlServer"
# ! Check: Get-InstalledModule
# ---------
# Install-Module SQLServer
# Check if SQLServer commands  are available!
# Get-Command -Module SQLServer |select Name | Format-Wide
# ================================================================

# Show SQL PS Commands
Get-Command -Module SQlPS |select Name | Format-Wide
Get-Command -Module SQlServer |select Name | Format-Wide