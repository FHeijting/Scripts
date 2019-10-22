$groups = Import-Csv C:\temp\Groepen.csv -Delimiter ';'

$path = "OU=Application,OU=Groups,OU=FvLUsers,DC=fvlprod,DC=fvl"
#$path = "OU=Data,OU=FvLGroups,DC=fvlprod,DC=fvl"

ForEach ($groep in $groups){

new-ADGroup -path $path -name $groep.Local -GroupScope DomainLocal -Description $groep.DESCRIPTIONLocal  
new-ADGroup -path $path -name $groep.Global -GroupScope Global -Description $groep.DESCRIPTIONGlobal 
Add-ADGroupMember -Identity $groep.Local -Members $groep.Global 

# Enable last line for Azure!
# Add-ADGroupMember -Identity A-FVL-G-Office365 -Members $groep.Global 

}

