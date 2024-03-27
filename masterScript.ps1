$installPath = 'C:\ops'

$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$user = (Get-ItemProperty -Path $regPath -Name DefaultUserName).DefaultUserName
$pass = ConvertTo-SecureString -String ((Get-ItemProperty -Path $regPath -Name DefaultPassword).DefaultPassword) -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "mundfish\$user", $pass

#start part2 from admin
Write-Host "Start part 2 of script, run as administrator. Working with choco, installing packages"
Start-Process powershell -ArgumentList "$installPath\pcInstallArtefacts\PsSetupPart2.ps1" -Wait

#start part3 from user
Write-Host "Start of third part of script. Run as user. Working with p4 and UGS"
if ($user -ne $null -and $pass -ne $null) {
    Start-Process PowerShell -ArgumentList "$installPath\pcInstallArtefacts\PsSetupPart3user.ps1" -Credential $credential -Wait
}
else {
    Start-Process PowerShell -ArgumentList "$installPath\pcInstallArtefacts\PsSetupPart3user.ps1" -Credential "mundfish\" -Wait
}    

#start part4 from admin
Write-Host "Start of last part of script. Run as administrator."
Start-Process powershell -ArgumentList "$installPath\pcInstallArtefacts\PsSetupPart4.ps1" -Wait