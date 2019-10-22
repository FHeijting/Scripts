# Core-Install-SCCM_Updates.ps1

function UPDATES {
write-host “” # line break
# define install updates function
function install_updates {
# get missing updates
$updates = Get-WmiObject -Class CCM_SoftwareUpdate -Namespace root\CCM\ClientSDK | Where-Object -FilterScript { $_.EvaluationState -eq “0” }
# exit script if no updates are found
If ( $updates -eq $null ) {
write-host “No updates found.” -foregroundcolor green
break }
write-host “” # line break
write-host “Available Updates:” -ForegroundColor Green
# display numbered list of update names
$display_updates = $updates | Select-Object Name
$f_display_updates = @()
# set numbers to 0
$up_num = 0
ForEach ( $display_update in $display_updates ) { $f_display_updates += $display_update.Name }
ForEach ( $f_display_update in $f_display_updates ) {
$up_num = $up_num + 1 # increment numbered list
write-host $up_num ” ” $f_display_update # display number and app name (ex. 1 Firefox)
}
write-host “” # line break
# allow for end user input of update number
write-host ‘Which update(s) would you like to install? (seperate with comma “,”)’ -foregroundcolor green
write-host ‘To install all updates, type “All”.’ -foregroundcolor green
$up_sel = Read-Host
If ( $up_sel -eq “All” ) { $sel_updates = $updates } # assigns all updates for installation
# assigns selected updates for installation
Else {
$f_up_sels = $up_sel.split(“,”) # splits string of update numbers
# assign selected application for installation
$sel_updates = @()
ForEach ( $f_up_sel in $f_up_sels ) {
$f_up_sel_sub = $f_up_sel – 1
$sel_updates += $updates[$f_up_sel_sub] }
}
# captures and formats update names for later use
$update_names = $sel_updates | Select-Object Name
$f_update_names = @()
ForEach ( $update_name in $update_names ) {
$s_update_name = “$update_name”
$f_update_names += $s_update_name.substring(7).trim(“}”)
}
write-host “” # separate update list and installation prompt
write-host “”
write-host “Beginning Installation” -foregroundcolor green # shows that updates have started
write-host “” # line break
# declare array for failed updates
$failed_updates = @()
# formats updates by just getting those that are required (ComplianceState=0). Converts updates to WMI so that they can be installed.
ForEach ( $sel_update in $sel_updates ) {
$f_update = @($sel_update | ForEach-Object {if($_.ComplianceState -eq 0){[WMI]$_.__PATH}})
$install_name = $sel_update | Select-Object Name
# Installs updates
$u_wmi_output = “”
$u_wmi_output = ([wmiclass]’ROOT\ccm\ClientSdk:CCM_SoftwareUpdatesManager’).InstallUpdates($f_update)
# wait until update process is seen, then disappears
Do {
$up_check = “”
$up_check = get-process | Where-Object -filterscript { $_.ProcessName -eq “wuauclt” }
}
Until ( $up_check -ne $null )
wait-process -name wuauclt
sleep -s 2
# write result
$s_install_name = “$install_name”
$f_install_name = $s_install_name.substring(7).trim(“}”)
$eval_state = “”
$eval_state = (Get-WmiObject -Class CCM_SoftwareUpdate -Namespace root\CCM\ClientSDK | Where-Object -filterscript { $_.Name -like “*$f_install_name*” }).EvaluationState
If ( $eval_state -eq “13”) {
$failed_updates += $f_install_name }
Else { write-host “Success – $f_install_name” -foregroundcolor green }
}
If ( $failed_updates -ne $null ) {
write-host “”
write-host “Failed Updates:” -foregroundcolor red
ForEach ($failed_update in $failed_updates) {
write-host $failed_update -foregroundcolor red }
}
write-host “” # line break
# determine if there is a pending reboot
$u_reboot = [wmiclass]”\\localhost\root\ccm\ClientSDK:CCM_ClientUtilities”
$u_result = $u_reboot.DetermineIfRebootPending() | Select-Object RebootPending
$u_p_reboot = $u_result.RebootPending
# does check for any pending reboots (eval state 8) and alerts if they are required
If ( $u_p_reboot -eq “true” )
{ write-host “Reboot Required.” -foregroundcolor red
write-host ‘Do you want to reboot now? If yes, type “Yes”. If no, type “No”.’ -foregroundcolor red
$reboot_sel = Read-Host
If ($reboot_sel -eq “Yes”) { restart-computer }
If ($reboot_sel -eq “No”) { }
}
Else { write-host “Reboot not Required.” -foregroundcolor green }
} # end of install_updates function
# determine if there is a pending reboot
$reboot = [wmiclass]”\\localhost\root\ccm\ClientSDK:CCM_ClientUtilities”
$result = $reboot.DetermineIfRebootPending() | Select-Object RebootPending
$p_reboot = $result.RebootPending
If ( $p_reboot -eq “true” ) {
# presents confirmation screen to apply updates
$message = “Reboot Pending. Do you want to continue installing updates?”
$yes = New-Object System.Management.Automation.Host.ChoiceDescription “&Yes”, `
“Installs all available updates.”
$no = New-Object System.Management.Automation.Host.ChoiceDescription “&No”, `
“Exits script.”
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch ($result)
{
1 { break } # stops script if NO
0 {
write-host “” # line break
install_updates }
}
}
Else {
write-host “” # line break
install_updates
}
} # end of UPDATES function

# allow for end user input to select Updates
write-host ‘Do you want to install Updates?’ -foregroundcolor green
write-host ‘Type “U” for Updates.’ -foregroundcolor green
$selection = Read-Host
If ( $selection -eq “U” ) { UPDATE! }
If ( ($selection -ne “S”) -AND ($selection -ne “U”) ) { write-host “Unexpected input. Please relaunch script.” -foregroundcolor red }
