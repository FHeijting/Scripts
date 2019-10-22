# Check-CPU-NumberOfCores.ps1
Get-WmiObject –class Win32_processor | ft systemname,Name,DeviceID,NumberOfCores,NumberOfLogicalProcessors, Addresswidth 

# Get-WmiObject –class Win32_processor | select *
# Ha!Skqp9GfvFBVbFM
