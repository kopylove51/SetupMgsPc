#search & run WorkspaceSetup.bat
$installPath = 'C:\ops'
Start-Transcript -Append "$installPath\Logs\psSetupLog4.txt"
$rootDerectory = Get-Content -Path "$installPath\rootDerectoryP4.txt"
$pathToWorkspaceSetupBat = (Get-ChildItem -Path $rootDerectory -Recurse -Filter "WorkspaceSetup.bat").FullName
Write-Host "run WorkspaceSetup.bat"
Start-Process -FilePath $pathToWorkspaceSetupBat -Wait

#delete autologin
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value 0
Remove-ItemProperty -Path $regPath -Name "DefaultDomainName"
Remove-ItemProperty -Path $regPath -Name "DefaultUserName"
Remove-ItemProperty -Path $regPath -Name "DefaultPassword"
Write-Host "Remove autologin"

#delete Artefacts
Remove-Item -Path "$installPath\Variable.txt", "$installPath\pcInstallArtefacts", "$installPath\rootDerectoryP4.txt" -Recurse
Write-Host "Remove install artefacts"
Unregister-ScheduledTask -TaskName "pssetup" -Confirm:$false
Write-Host "Remove task from the scheduler"

Stop-Transcript