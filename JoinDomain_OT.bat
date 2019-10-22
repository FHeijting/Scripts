@Echo Off

Title Postconfigure Machine and domain join

Set JoinUsr=OT\usttsp
Set JoinDom=ot.otam.fvl
Set JoinDNB=OT
Set JoinOU="OU=Desktop,OU=Win7,OU=FvlWorkstations,DC=ot,DC=otam,DC=fvl"

Echo Joining machine to domain...
Echo Enter the password for the %JoinUsr% account :
Netdom join . /domain:%JoinDom% /OU:%JoinOU% /UserD:%JoinUsr% /PasswordD:*
Set Retval=%ErrorLevel%

if %Retval%==0 (
  Timeout /t 10
  Echo Preparing machine for domain...
  reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\WinLogon" /v DefaultDomain /t REG_SZ /d %JoinDNB%

  Echo Installing McAfee DLP Agent...
  if "%ProgramFiles(x86)%"=="C:\Program Files (x86)" (
    Echo Installing DLP - x64
    C:\Management\McAfee\DLP\Agent\v9.3.100.52\05_MSI\x64\DLPAgentInstaller.x64.exe /qb REBOOT=ReallySuppress
  ) else (
    Echo Installing DLP - x86
    C:\Management\McAfee\DLP\Agent\v9.3.100.52\05_MSI\x86\DLPAgentInstaller.x86.exe /qb REBOOT=ReallySuppress
  )

  Echo Setting domain specific parameters ...
  powershell -ExecutionPolicy ByPass -File C:\Management\VDI\Prep-MasterImage.ps1 -Environment %JoinDNB%

  Echo Clean local C:\Drivers path. It is a little big. Multiple driversets present  
  rd C:\Drivers /s /q
  Del %Public%\Desktop\JoinDomain*.lnk

  Shutdown /r /t 5
  del %~dps0JoinDomain*.bat
) ELSE (
  Echo Error joining domain !!!!
  Echo Error number: %Retval%
  Pause
)
