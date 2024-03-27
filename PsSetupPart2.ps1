#need run from admin
$installPath = 'C:\ops'
$nexusAddress = "http://nexus.mundfish.lan:8700/repository"

$mgsChocoSources = @(
    [PSCustomObject]@{
        "name" = "mgs"
        "priority" = 0
        "address" = "mgs-proxy/"
    },
    [PSCustomObject]@{
        "name" = "choco-proxy"
        "priority" = 1
        "address" = "chocolatey-proxy/"
    }
)

[bool]$isSourcesUpdated = $false

foreach ($source in $mgsChocoSources) {
    $sourceStringForCheck = "$($source.name) - $nexusAddress/$($source.address) | Priority $($source.priority)"
    if ($null -ne (& C:\ProgramData\chocolatey\bin\choco.exe source | Select-String ([regex]::Escape($sourceStringForCheck)))) {
        Write-Output "Chocolatey source $($source.name) is correct"
    } else {
        Write-Output "Chocolatey source $($source.name) is not correct"
        Write-Output "Updating source list"
        & C:\ProgramData\chocolatey\bin\choco.exe source add "-n=$($source.name)" -s "'$nexusAddress/$($source.address)'" "--priority=$($source.priority)"
        Write-Output "Chocolatey source updated"
    }
}
Write-Host "Mgs-choco source has been installed"

#installing choco packages
$userProjectConfig = Get-Content -Path "$installPath\Variable.txt"

if ($userProjectConfig -eq 1) 
    {
       $userChocoPackages = @("mgs-atomicheart-engine-build", "mgs-unrealgamesync")
       $p4stream = "//AtomicHeart/Prototyping-WinAudio"
       $p4streamName = "Prototyping-WinAudio"
       $p4user = "common_user"
       $wsOptions="noallwrite noclobber nocompress unlocked nomodtime rmdir"
    }
elseif ($userProjectConfig -eq 2) 
    {
        $userChocoPackages = @("mgs-unrealgamesync")
        $p4stream = "//UE5/Mundfish_UGS"
        $p4streamName = "Mundfish_UGS"
        $p4user = "common_ng_projects_user"
        $wsOptions="noallwrite noclobber compress unlocked nomodtime rmdir"
    }

#install p4 & p4v
Invoke-WebRequest -Uri "https://www.perforce.com/downloads/perforce/r24.1/bin.ntx64/p4vinst64.exe" -OutFile "$installPath\pcInstallArtefacts\p4vinst64.exe"
Start-Process -FilePath "$installPath\pcInstallArtefacts\p4vinst64.exe" -ArgumentList "/s REMOVEAPPS=P4ADMIN,P4MERGE" -Wait
if (-not (Test-Path "C:\Program Files\Perforce\p4v.exe")) {
    Start-Process -FilePath choco -ArgumentList "install p4 p4v -y" -Wait
    }
Start-Process -FilePath choco -ArgumentList "install googlechrome notepadplusplus slack 7zip geforce-game-ready-driver $userChocoPackages -y" -Wait
Stop-process -name "UnrealGameSyncLauncher" -force
Write-Host "Mgs-choco packages has been installed"


#update environment variables after installing packages
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv
Write-host ("environment variables refreshed")