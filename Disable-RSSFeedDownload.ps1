
# http://pubs.vmware.com/view-50/index.jsp#com.vmware.view.administration.doc/GUID-2A5822C3-C88C-4B4D-90CC-10CB41C39EC7.html

# C:\WINDOWS\system32\msfeedssync.exe disable
Start-Process -FilePath $Env:SystemRoot\system32\msfeedssync.exe -ArgumentList "disable" -Wait

#
# Remove current schedules
#
Get-ChildItem C:\windows\system32\tasks -Force -Recurse |  Where {$_.Name -match 'User_Feed_Synchronization'} | Remove-Item -Force -ErrorAction SilentlyContinue

