##need run from user
$installPath = 'C:\ops'
Start-Transcript -Append "$installPath\Logs\psSetupLog.txt"
$userProjectConfig = Get-Content -Path "$installPath\Variable.txt"
$regUgsPath = "HKCU:\SOFTWARE\Epic Games\UnrealGameSync"
$ugsUserDerectory = "$env:LOCALAPPDATA\UnrealGameSync\"

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

#request to select stream home directory
$steamDerectoryObject = New-Object -comObject Shell.Application
$steamDerectoryFolder = $steamDerectoryObject.BrowseForFolder(0, 'Select perforce root derectory', 1,0)
if ($steamDerectoryFolder -ne $null) {
    $rootDerectory = $steamDerectoryFolder.Self.Path
}

#creating p4WS
$p4clientName = "$env:USERNAME"+"_"+"$p4streamName"
p4 set P4USER=$p4user
$p4pass = Read-Host "enter password common_ng_projects_user" -AsSecureString
$p4pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p4pass))
$p4LoginOutput = (echo $p4pass | p4 login 2>&1)
while ($p4LoginOutput -like "*Password invalid.*") {
    Write-Host "Incorrect password. Try again."
    $p4pass = Read-Host "enter password common_ng_projects_user" -AsSecureString
    $p4pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p4pass))
    $p4LoginOutput = (echo $p4pass | p4 login 2>&1)
}
#Pause
p4 -d  $rootDerectory client -o $p4clientName `
    |% {$_ -replace "Options:	noallwrite noclobber nocompress unlocked nomodtime normdir", "Options:	$wsOptions"} `
    |% {$_ -replace "SubmitOptions:	submitunchanged", "SubmitOptions:	revertunchanged`n`nStream:	$p4stream"}| p4 client -i
Write-Host "p4 ws has been created"
#Pause

#sync p4 ws
p4 set p4client=$p4clientName
p4 info
Start-Process p4 -ArgumentList "sync //UE5/Development/AtomicOnline/AtomicOnline.uproject" -Wait
Start-Process p4 -ArgumentList "sync //UE5/Development/WorkspaceSetup.bat" -Wait
Write-Host "p4 ws has been synced"
#Pause

#$p4qtPath = "$env:USERPROFILE\.p4qt\ApplicationSettings.xml"
#$p4config = Get-Content -Path $p4qtPath
#$newP4config = $p4config -replace '<Int varName="ConnectionStartOption">0</Int>', '<Int varName="ConnectionStartOption">1</Int>'
#$newP4config | Set-Content -Path $p4qtPath
#Start-process p4v

#block of work with unreal-game-sync
if ($userProjectConfig -eq 2) {
        if (-not (Test-Path $regUgsPath)) {
            New-Item -Path "HKCU:\SOFTWARE\Epic Games\UnrealGameSync" -Force
            Write-Host "Epic Games and UnrealGameSync folders have been created"
        } else {
            Write-Host "path in registry already exists"
        }
        #Pause

        #create entries in the registry
        Set-ItemProperty -Path $regUgsPath -Name "DepotPath" -Value "//ue5/unrealgamesync/"
        Set-ItemProperty -Path $regUgsPath -Name "ServerAndPort" -Value "perforce:1666"
        Set-ItemProperty -Path $regUgsPath -Name "UserName" -Value $p4user
        Write-Host "registry entries added"
        #Pause

        #copy configuration file templates and change them
        #Start-Process git -ArgumentList "clone --progress https://kopylove51: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@github.com/kopylove51/Work-diary-and-notes.git `"$installPath\pcInstallArtefacts`"" -Wait
        if (-not (Test-Path $ugsUserDerectory)) {
            New-Item -ItemType Directory -Path $ugsUserDerectory 
        }
        #working with strings lastProject & OpenProjects
        $ClientPath = "//"+$p4clientName+"/AtomicOnline/AtomicOnline.uproject"
        $LocalPath = ((Get-ChildItem -Path $rootDerectory -Recurse -Filter "AtomicOnline.uproject").FullName).Replace("\", "\\")
        Write-Host "lastProject & OpenProjects lines received:`nClientPath = $ClientPath`nLocalPath = $LocalPath"
        #Pause

        #copy the templates to the destination directory
        Copy-Item -Path "$installPath\pcInstallArtefacts\UnrealGameSyncV2.ini", "$installPath\pcInstallArtefacts\Global.json" -Destination $ugsUserDerectory #-Force
        Write-Host "templates copied in $ugsUserDerectory"
        #Pause

        #converting templates into a working version
        $ugsIniFile = Get-Content -Path "$ugsUserDerectory\UnrealGameSyncV2.ini"
        $newUgsIniFile = $ugsIniFile -replace "replace_ClientPath", "$ClientPath" | ForEach-Object {$_ -replace "replace_LocalPath", "$LocalPath"}
        $newUgsIniFile | Set-Content -Path "$ugsUserDerectory\UnrealGameSyncV2.ini"
        Get-Content -Path "$ugsUserDerectory\UnrealGameSyncV2.ini"
        Write-Host "UGS config files addided"
        #Pause

        Start-process -FilePath "C:\Program Files (x86)\UnrealGameSync\UnrealGameSyncLauncher.exe"
    }

$rootDerectory | Out-File -FilePath "$installPath\Variable.txt" # -Append
Stop-Transcript


   