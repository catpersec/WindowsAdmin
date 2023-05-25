
try {
    $install = choco -v;
	Write-Host "Chocolatey installed. Chocolatey version: " $install " . Software installation will proceed."
}  
catch {
    Write-Host "Chocolatey not installed. Chocolatey installation will be performed"  -ForegroundColor Yellow
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    #invoke-expression 'cmd /c start powershell -Command {write-host "hello";read-host}'
    Write-Host ""
    Write-Host "Powershell restart required!"
	exit
}


choco feature enable -n allowGlobalConfirmation

# NOTEPADS
## NOTION
#choco install notion --force

# TO-DO TOOLS
## TICKTICK
# MANUAL DOWNLOAD!

## Text editors
#choco install notepadplusplus.install --force

## Image editors
#choco install paint.net --force
#choco install gimp --force

## Video players
#choco install vlc --force
#choco install potplayer --force

## Music players
#choco install spotify --force

## Browsers
# choco install Firefox --force
# choco GoogleChrome --force
# choco install Opera --force

## PDF reading
#choco install adobereader --force
#choco install FoxitReader --force

## PDF editors
#choco install PDFXchangeEditor --force

## Archives
#choco install 7zip.install --force

## Chat apps
#choco install discord --force

# Password manager
## BITWARDEN
#choco install Bitwarden --force

# Manage windows
## OOSU10 - START (uncomment all lines in section in order to create shurtcut to oosu on desktop)
# $shutup_install = choco install shutup10 --force
# $pattern = "Software installed to '(.+)'"
# $regex = [regex]::new($pattern)
# $shutup10_install_path_raw = $regex.Match($shutup_install)
# if ($shutup10_install_path_raw.Success) {
#     $shutup10_install_path_only = $shutup10_install_path_raw.Groups[1].Value
# } else {
# }
# $WshShell = New-Object -comObject WScript.Shell
# $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\shutup10.lnk")
# $target_path = $shutup10_install_path_only + "\tools\OOSU10.exe"
# $Shortcut.TargetPath = $target_path
# $Shortcut.Save()
# Write-Host "O&O Shutup10 installed."
## OOSU10 - END


## Windows tools
#choco install windirstat --force
#choco install powershell-core --force


#resources
#https://www.reddit.com/r/chocolatey/comments/esqqfz/is_it_possible_to_install_multiple_packages_at/