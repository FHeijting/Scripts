<# Filename: Remove_Chrome.ps1

Description: Removes file traces of Google Chrome from all user profiles directories
and currently logged on user registry keys. There are no input or output parameters,
but if you want to do a dry run you can add -whatif at the end of each Remove-Item command.

Purpose: When Chrome for Business was rolled out not all traces of user installed Chrome was removed. In order to get rid
of reported security vulnerabilities there is a need to manually remove these files/keys.
#>
# Set the root directory where User Chrome is installed.

$RootDirectory= "C:\Users\*\AppData\Local\Google\Chrome\Application\*"
$ProfileStartMenuShortcut= "C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Google Chrome"
$ProfileDesktopShortcut= "C:\Users\*\Desktop\Google Chrome.lnk"

#Check for HKey Users registry drive. Create if needed
#if(!(Get-PSDrive -name HKU)){
New-PSDrive HKU Registry HKEY_USERS
#}
# Set Registry paths for user installed chrome. (Users who are not logged on will not be checked)
$ChromeAddRemoveKey="HKU:\S-1-5-21*\Software\Microsoft\Windows\CurrentVersion\Uninstall"
$ChromeKey= "HKU:\S-1-5-21*\Software\Google\Update"

# Delete all files under Chrome's user install directory
Remove-Item -recurse -force $RootDirectory

# Delete Chrome shortcuts from user Profiles
Remove-Item -recurse -force $ProfileStartMenuShortcut
Remove-Item -force $ProfileDesktopShortcut

# Find and remove all user specific chrome installs from the registry.
Get-ChildItem $ChromeAddRemoveKey -ErrorAction SilentlyContinue | Where-Object {
($_.PSChildName -eq 'Google Chrome') -or
($_.PSChildName -eq 'Chrome')
} | Remove-Item -force
Get-ChildItem $ChromeKey -ErrorAction SilentlyContinue -recurse | Where-Object {
($_.PSChildName -eq '{8A69D345-D564-463C-AFF1-A69D9E59630F}') -or
($_.PSChildName -eq '{8A69D345-D564-463C-AFF1-A69D9E530F96}') -or
($_.PSChildName -eq '{00058422-BABE-4310-9B8B-B8DEB5D0B68A}')
} | Remove-Item -recurse -force
