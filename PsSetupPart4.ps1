#search & run WorkspaceSetup.bat
$installPath = 'C:\ops'
$rootDerectory = Get-Content -Path "$installPath\Variable.txt"
$pathToWorkspaceSetupBat = (Get-ChildItem -Path $rootDerectory -Recurse -Filter "WorkspaceSetup.bat").FullName
Start-Process -FilePath $pathToWorkspaceSetupBat

#delete autologin
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value 0
Remove-ItemProperty -Path $regPath -Name "DefaultDomainName"
Remove-ItemProperty -Path $regPath -Name "DefaultUserName"
Remove-ItemProperty -Path $regPath -Name "DefaultPassword"

#delete Artefacts
Remove-Item -Path "$installPath\Variable.txt", "$installPath\pcInstallArtefacts" -Recurse