# Create-Managed-Service-Accounts.ps1

Import-module activedirectory
  
# $gMSAName = 'gMSA_Account_Name' ## Replace this value with new gMSA Name
# $serverList = 'Server001','Server002','Server003','Server004','Server005' ## Replace with Server Names
# $adOU = 'ou=Managed Service Accounts,OU=Service Accounts,DC=your_company,DC=com' ## Replace with actual AD OU
  
$gMSAName = 'gMSATASKSCHDLR'
$serverList = ','
$adOU = 'ou=Managed Service Accounts,DC=FVLPROD,DC=FVL'

  
## Checking whether organizational unit exists, if not create it.
$ous = dsquery ou "$adOU"
if ($ous.count -eq 0) {
    dsadd ou "$adOU"
}

## Create a Group Managed Service Account
$NameOfServersAccountIsToBeUsedOn = $serverList.ForEach{ return (Get-ADComputer $_)  }
Write-Output $NameOfServersAccountIsToBeUsedOn

##Creating the gMSA
New-ADServiceAccount -Name $gMSAName -Path "$adOU" -DNSHostName "$gMSAName.FVLPROD.FVL" -PrincipalsAllowedToRetrieveManagedPassword $NameOfServersAccountIsToBeUsedOn -TrustedForDelegation $true -Whatif
