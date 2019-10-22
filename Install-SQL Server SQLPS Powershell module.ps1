# 
# 1e Install : 2016 System CLR Types for Microsoft® SQL Server®
# 2e Install : 2016 SQL Server® Shared Management Objects
# 3e Install : 2016 PowerShell Extensions for Microsoft SQL Server
# Open Powershell under Adminrights!
# D:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS
D:
cd "D:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS"
Import-Module -Name SQLPS
# Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned

Get-Command -Module SQlPS |select Name | Format-Wide

# To add locations to the PSModulePath variable
$env:PSModulePath = $env:PSModulePath + ";D:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS"

