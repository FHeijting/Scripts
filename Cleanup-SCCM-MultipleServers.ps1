# Cleanup-SCCM-MultipleServers.ps1
# =========================================
$strCategory = "computer" 
$strOperatingSystem = "Windows*Server*" 

$output = Get-Content -Path C:\Users\BPATFR\_Scripts\PS1\Cleanup_CCMCach-Servers.ini
#$output = 'ETLTWA01'

$Counter = 0
$c1 = 0

foreach ($computer in $output){
    # Delete all Folders in C:\put_folder_here older than 1 day(s)
    $Path = "C$\windows\ccmcache"
    $Daysback = "-1"
    $CurrentDate = Get-Date
    $DatetoDelete = $CurrentDate.AddDays($Daysback)
    $Counter++
   
    $c1++
    Write-Progress -id 0 -Activity 'Processing CcmCache Folder Cleanup' -Status "Processing $($c1) of $($output.count)" -CurrentOperation $computer -PercentComplete (($counter / $output.count) * 100)
    Start-Sleep -Milliseconds 100
   
    
    $Files = Get-ChildItem -Recurse "\\$computer\$path\*"  | Where-Object {$_.LastWriteTime -lt $DatetoDelete }
    $c2 = 0
    Foreach ($file in $files){
    $c2++
    Write-Progress -Id 1 -ParentId 0 -Activity 'Getting/Removing Files' -Status "Processing $($c2) of $($Files.count)" -CurrentOperation $File -PercentComplete (($c2/$Files.count) * 100)
    Start-Sleep -Milliseconds 100
    Remove-Item -Path $file # -Confirm:$false -Force -Recurse -Verbose 
    #Remove-Item $files -ErrorAction SilentlyContinue -Confirm:$false -Verbose
    }

    $folders = gci "\\$computer\$path\" -Directory -Recurse -Verbose | where {(gci $_.FullName).count -eq 0} | select -expandproperty FullName 
    $c3 = 0
    ForEach ($folder in $folders){
    $c3++
    Write-Progress -Id 1 -ParentId 0 -Activity 'Getting/Removing Folders' -Status "Processing $($c3) of $($folders.count)" -CurrentOperation $folder -PercentComplete (($c3/$folders.count) * 100)
    Start-Sleep -Milliseconds 100
    Remove-Item $folder -verbose 
    }
} 
# ========================================= 
