#FindDisabledUserAccounts.ps1
#Requires -Version 2.0 
$location = "U:\LTB 1\2017\08\disableduseraccounts.txt"
$filter = “(&(objectClass=user)(objectCategory=person))” 
$users = ([adsiSearcher]$Filter).findall() 
foreach($suser in $users) 
{ 
“Testing $($suser.properties.item(“”distinguishedname””))” 
$user = [adsi]“LDAP://$($suser.properties.item(“”distinguishedname””))” 
$uac=$user.psbase.invokeget(“useraccountcontrol”) 
if($uac -band 0x2)  
 { write-host -foregroundcolor red “`t account is disabled” }  
#{ write-output -foregroundcolor red “`t account is disabled” >> $location }  
ELSE  
{ write-host -foregroundcolor green “`t account is not disabled” } 
} #foreach 
