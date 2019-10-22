cls

# directory where my scripts are stored

# $psdir="C:\Management\Scripts\AutoLoadProfile"  

# load all 'autoload' scripts

# Get-ChildItem "${psdir}\*.ps1" | %{.$_} 

Write-Host "Custom PowerShell Environment Has Been Loaded"
Write-Host "Have a Nice Day" 


function lastboot {
	Param(
    $Computer = $env:COMPUTERNAME
    )
	invoke-command -computername $Computer -scriptblock {Get-CimInstance -ClassName win32_operatingsystem | select csname, lastbootuptime} 
	}

function PasswordReset {
	$Name = Read-Host 'Enter Username'
	$Pass = Read-Host 'Enter Password' -AsSecureString
	set-ADAccountPassword -identity $Name -NewPAssword $Pass -reset
	Unlock-ADAccount $Name 
	}
	
Function CheckCert {
	$Srv = @(Get-ADComputer -Filter 'operatingsystem -like "*Windows Server*"' -Properties operatingsystem | Select-Object name, operatingsystem)
	Invoke-Command -Computername $Srv.name -Scriptblock {Get-ChildItem -path Cert:\LocalMachine\My -recurse -expiringindays 60 } -ErrorAction SilentlyContinue| Select-Object -Property PSComputerName,Issuer,FriendlyName,NotAfter,Subject,ThumbPrint,EnhancedKeyUsageList 
	}

Function CheckGPO {
	Get-GPO -all | Sort ModificationTime -Descending | Select -First 25 | FT DisplayName, ModificationTime
	}

###########################################################################

function trigger-AvailableSupInstall
{
 Param
(
 [String][Parameter(Mandatory=$True, Position=1)] $Computername,
 [String][Parameter(Mandatory=$True, Position=2)] $SupName
 
)
Begin
{
 $AppEvalState0 = "0"
 $AppEvalState1 = "1"
 $ApplicationClass = [WmiClass]"root\ccm\clientSDK:CCM_SoftwareUpdatesManager"
}
 
Process
{
If ($SupName -Like "All" -or $SupName -like "all")
{
 Foreach ($Computer in $Computername)
{
 $Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer | Where-Object { $_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*"})
 Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Application) -Namespace root\ccm\clientsdk -ComputerName $Computer
 
}
 
}
 Else
 
{
 Foreach ($Computer in $Computername)
{
 $Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer | Where-Object { $_.EvaluationState -like "*$($AppEvalState)*" -and $_.Name -like "*$($SupName)*"})
 Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Application) -Namespace root\ccm\clientsdk -ComputerName $Computer
 
}
 
}
}
End {}
}

###########################################################################
Function CheckAutomaticServices {
	
Param(
[Parameter(ValueFromPipeline=$True, Mandatory=$True)]
$Computer
)


Get-WmiObject Win32_Service -ComputerName $Computer |` 
    where     {($_.startmode -like "*auto*") -and ` 
            ($_.state -notlike "*running*")}|` 
            select DisplayName,Name,StartMode,State|ft -AutoSize
            }
	
############################################################################
Function GetMembership {

Param(
[Parameter(ValueFromPipeline=$True, Mandatory=$True)]
$User
)
get-adprincipalgroupmembership $user | Select Name
}

############################################################################

Function ConvertSIDtoUser {

Param(
[Parameter(ValueFromPipeline=$True, Mandatory=$True)]
$SID)

#$SID ='S-1-5-21-1924530255-1943933946-939161726-500'
$objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
$objUser = $objSID.Translate([System.Security.Principal.NTAccount])
Write-Host "Resolved user name: " $objUser.Value
}

############################################################################

Function ConvertUSertoSID {

Param(
[Parameter(ValueFromPipeline=$True, Mandatory=$True)]
$User)

#$user ='TestDomain\Morgan'
$objUser = New-Object System.Security.Principal.NTAccount($user)
$objSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
Write-Host "Resolved user's sid: " $objSID.Value
}

############################################################################

function Get-GroupHierarchy ($searchGroup)
{
import-module activedirectory
$groupMember = get-adgroupmember $searchGroup | sort-object objectClass -descending
   foreach ($member in $groupMember)
    {Write-Host $member.objectclass,":", $member.name;
    if ($member.ObjectClass -eq "group")
        {Get-GroupHierarchy $member.name}}
} 

############################################################################
#Requires -Version 2.0
Function Get-LockedOutLocation
{
<#
.SYNOPSIS
	This function will locate the computer that processed a failed user logon attempt which caused the user account to become locked out.

.DESCRIPTION
	This function will locate the computer that processed a failed user logon attempt which caused the user account to become locked out. 
	The locked out location is found by querying the PDC Emulator for locked out events (4740).  
	The function will display the BadPasswordTime attribute on all of the domain controllers to add in further troubleshooting.

.EXAMPLE
	PS C:\>Get-LockedOutLocation -Identity Joe.Davis


	This example will find the locked out location for Joe Davis.
.NOTE
	This function is only compatible with an environment where the domain controller with the PDCe role to be running Windows Server 2008 SP2 and up.  
	The script is also dependent the ActiveDirectory PowerShell module, which requires the AD Web services to be running on at least one domain controller.
	Author:Jason Walker
	Last Modified: 3/20/2013
#>
    [CmdletBinding()]

    Param(
      [Parameter(Mandatory=$True)]
      [String]$Identity      
    )

    Begin
    { 
        $DCCounter = 0 
        $LockedOutStats = @()   
                
        Try
        {
            Import-Module ActiveDirectory -ErrorAction Stop
        }
        Catch
        {
           Write-Warning $_
           Break
        }
    }#end begin
    Process
    {
        
        #Get all domain controllers in domain
        $DomainControllers = Get-ADDomainController -Filter *
        $PDCEmulator = ($DomainControllers | Where-Object {$_.OperationMasterRoles -contains "PDCEmulator"})
        
        Write-Verbose "Finding the domain controllers in the domain"
        Foreach($DC in $DomainControllers)
        {
            $DCCounter++
            Write-Progress -Activity "Contacting DCs for lockout info" -Status "Querying $($DC.Hostname)" -PercentComplete (($DCCounter/$DomainControllers.Count) * 100)
            Try
            {
                $UserInfo = Get-ADUser -Identity $Identity  -Server $DC.Hostname -Properties AccountLockoutTime,LastBadPasswordAttempt,BadPwdCount,LockedOut -ErrorAction Stop
            }
            Catch
            {
                Write-Warning $_
                Continue
            }
            If($UserInfo.LastBadPasswordAttempt)
            {    
                $LockedOutStats += New-Object -TypeName PSObject -Property @{
                        Name                   = $UserInfo.SamAccountName
                        SID                    = $UserInfo.SID.Value
                        LockedOut              = $UserInfo.LockedOut
                        BadPwdCount            = $UserInfo.BadPwdCount
                        BadPasswordTime        = $UserInfo.BadPasswordTime            
                        DomainController       = $DC.Hostname
                        AccountLockoutTime     = $UserInfo.AccountLockoutTime
                        LastBadPasswordAttempt = ($UserInfo.LastBadPasswordAttempt).ToLocalTime()
                    }          
            }#end if
        }#end foreach DCs
        $LockedOutStats | Format-Table -Property Name,LockedOut,DomainController,BadPwdCount,AccountLockoutTime,LastBadPasswordAttempt -AutoSize

        #Get User Info
        Try
        {  
           Write-Verbose "Querying event log on $($PDCEmulator.HostName)"
           $LockedOutEvents = Get-WinEvent -ComputerName $PDCEmulator.HostName -FilterHashtable @{LogName='Security';Id=4740} -ErrorAction Stop | Sort-Object -Property TimeCreated -Descending
        }
        Catch 
        {          
           Write-Warning $_
           Continue
        }#end catch     
                                 
        Foreach($Event in $LockedOutEvents)
        {            
           If($Event | Where {$_.Properties[2].value -match $UserInfo.SID.Value})
           { 
              
              $Event | Select-Object -Property @(
                @{Label = 'User';               Expression = {$_.Properties[0].Value}}
                @{Label = 'DomainController';   Expression = {$_.MachineName}}
                @{Label = 'EventId';            Expression = {$_.Id}}
                @{Label = 'LockedOutTimeStamp'; Expression = {$_.TimeCreated}}
                @{Label = 'Message';            Expression = {$_.Message -split "`r" | Select -First 1}}
                @{Label = 'LockedOutLocation';  Expression = {$_.Properties[1].Value}}
              )
                                                
            }#end ifevent
            
       }#end foreach lockedout event
       
    }#end process
   
}#end function