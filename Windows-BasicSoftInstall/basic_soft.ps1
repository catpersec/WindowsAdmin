try {
    $install = choco -v;
	Write-Host "Chocolatey installed. Chocolatey version: " $install " . Software installation will proceed."\
}  
catch {
    Write-Host "Chocolatey not installed. Chocolatey installation will be performed"  -ForegroundColor Yellow
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
	start-process powershell
    exit
    .\basic_soft.ps1
}

choco feature enable -n allowGlobalConfirmation

choco install notepadplusplus.install --force
choco install discord --force
choco install vlc --force
choco install Firefox --force
choco install spotify --force
choco install paint.net --force
choco install adobereader --force
choco install PDFXchangeEditor --force
choco install 7zip.install --force
choco install Bitwarden --force
choco install windirstat --force
choco install powershell-core --force
#resources
#https://www.reddit.com/r/chocolatey/comments/esqqfz/is_it_possible_to_install_multiple_packages_at/