
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

## Text editors
#choco install notepadplusplus.install --force

## Image editors
#choco install paint.net --force

## Video players
#choco install vlc --force

## Music players
#choco install spotify --force

## Browsers
#choco install Firefox --force
#choco GoogleChrome --force

## PDF reading
#choco install adobereader --force

## PDF editors
#choco install PDFXchangeEditor --force

## Archives
#choco install 7zip.install --force

## Chat apps
#choco install discord --force

## Security
#choco install Bitwarden --force

## Windows tools
#choco install windirstat --force
#choco install powershell-core --force


#resources
#https://www.reddit.com/r/chocolatey/comments/esqqfz/is_it_possible_to_install_multiple_packages_at/