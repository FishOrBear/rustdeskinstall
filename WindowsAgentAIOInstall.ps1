# Replace wanipreg and keyreg with the relevant info

$ErrorActionPreference= 'silentlycontinue'

If (!(test-path "c:\temp")) {
    New-Item -ItemType Directory -Force -Path "c:\temp"
}
cd c:\temp

If (!(test-path "C:\Program Files\Rustdesk\RustDesk.exe")) {
cd c:\temp

Invoke-WebRequest https://github.com/rustdesk/rustdesk/releases/download/1.1.9/rustdesk-1.1.9-windows_x64.zip -Outfile rustdesk.zip

expand-archive rustdesk.zip
cd rustdesk
start .\rustdesk-1.1.9-putes.exe --silent-install
}

# Set URL Handler
New-Item -Path "HKLM:\SOFTWARE\Classes\RustDesk" 
Set-ItemProperty -Path "HKLM:\SOFTWARE\Classes\RustDesk" -Name "(Default)" -Value "URL:RustDesk Protocol"
New-ItemProperty -Path "HKLM:\SOFTWARE\Classes\RustDesk" -Name "URL Protocol" -Type STRING
New-Item -Path "HKLM:\SOFTWARE\Classes\RustDesk\DefaultIcon" 
Set-ItemProperty -Path "HKLM:\SOFTWARE\Classes\RustDesk\DefaultIcon" -Name "(Default)" -Value "RustDesk.exe,0"
New-Item -Path "HKLM:\SOFTWARE\Classes\RustDesk\shell" 
New-Item -Path "HKLM:\SOFTWARE\Classes\RustDesk\shell\open" 
New-Item -Path "HKLM:\SOFTWARE\Classes\RustDesk\shell\open\command" 
Set-ItemProperty -Path "HKLM:\SOFTWARE\Classes\RustDesk\shell\open\command" -Name "(Default)" -Value '"C:\Program Files\RustDesk\RustDeskURLLauncher.exe" "%1"'
New-Item "C:\Program Files\RustDesk\urlhandler.ps1"
Set-Content "C:\Program Files\RustDesk\urlhandler.ps1" "`$url_handler = `$args[0]`n`$rustdesk_id = `$url_handler -creplace '(?s)^.*\:',''`nStart-Process -FilePath 'C:\Program Files\RustDesk\rustdesk.exe' -ArgumentList ""--connect `$rustdesk_id"""
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module ps2exe -Force
Invoke-ps2exe "C:\Program Files\RustDesk\urlhandler.ps1" "C:\Program Files\RustDesk\RustDeskURLLauncher.exe"
Remove-Item "C:\Program Files\RustDesk\urlhandler.ps1"

# Write config
If (!("C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\RustDesk.toml")) {
$username = ((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
New-Item C:\Users\$username\AppData\Roaming\RustDesk\config\RustDesk2.toml
Set-Content C:\Users\$username\AppData\Roaming\RustDesk\config\RustDesk2.toml "rendezvous_server = 'wanipreg' `nnat_type = 1`nserial = 0`n`n[options]`ncustom-rendezvous-server = 'wanipreg'`nkey = 'keyreg'`nrelay-server = 'wanipreg'`napi-server = 'https://wanipreg'"
}
else {
New-Item C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\RustDesk2.toml
Set-Content C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\RustDesk2.toml "rendezvous_server = 'wanipreg' `nnat_type = 1`nserial = 0`n`n[options]`ncustom-rendezvous-server = 'wanipreg'`nkey = 'keyreg'`nrelay-server = 'wanipreg'`napi-server = 'https://wanipreg'"
}

Start-sleep -s 20

# Get RustDesk ID

If (!("C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\RustDesk.toml")) {
$username = ((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
$rustid=(Get-content C:\Users\$username\AppData\Roaming\RustDesk\config\RustDesk.toml | Where-Object { $_.Contains("id") })
$rustid = $rustid.Split("'")[1]

$rustpword = (Get-content C:\Users\$username\AppData\Roaming\RustDesk\config\RustDesk.toml | Where-Object { $_.Contains("password") })
$rustpword = $rustpword.Split("'")[1]
Write-output "Config file found in user folder"
Write-output "$rustid"
Write-output "$rustpword"
}
else {
$rustid=(Get-content C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\RustDesk.toml | Where-Object { $_.Contains("id") })
$rustid = $rustid.Split("'")[1]

$rustpword = (Get-content C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\RustDesk.toml | Where-Object { $_.Contains("password") })
$rustpword = $rustpword.Split("'")[1]
Write-output "Config file found in windows service folder"
Write-output "$rustid"
Write-output "$rustpword"
}

Start-sleep -s 10

net stop rustdesk
net start rustdesk
