$installPath = 'C:\ops'

$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$user = (Get-ItemProperty -Path $regPath -Name DefaultUserName).DefaultUserName
$pass = ConvertTo-SecureString -String ((Get-ItemProperty -Path $regPath -Name DefaultPassword).DefaultPassword) -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "mundfish\$user", $pass

#start part2 from admin
Start-Process powershell -FilePath "$installPath\pcInstallArtefacts\PsSetupPart2.ps1" -Wait

#start part3 from user
Start-Process PowerShell -FilePath "$installPath\pcInstallArtefacts\PsSetupPart3user.ps1" -Credential $credential -Wait

#start part4 from admin
Start-Process powershell -FilePath "$installPath\pcInstallArtefacts\PsSetupPart4.ps1" -Wait