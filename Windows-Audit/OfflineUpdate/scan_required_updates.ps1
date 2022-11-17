Param()

$rootDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

$UpdateSession = New-Object -ComObject Microsoft.Update.Session 
$UpdateServiceManager  = New-Object -ComObject Microsoft.Update.ServiceManager

New-Item -Path "$rootDir" -Name "required_updates" -ItemType "directory"


Write-Output "Wybierz plik wsusscn2.cab z najnowsza baze aktualizacji"

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    Multiselect = $false # Multiple files can be chosen
	Filter = 'pliki .cab  (*.cab)|*.cab' # Specified file types
}
 
[void]$FileBrowser.ShowDialog()

$file = $FileBrowser.FileName;

If($FileBrowser.FileNames -like "*\*") {

	# Do something 
	$FileBrowser.FileName #Lists selected files (optional)
	
}

else {
    Write-Host "Cancelled by user"
}


$UpdateService = $UpdateServiceManager.AddScanPackageService("Offline Sync Service", "$file", 1) 
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()  
 
Write-Output "Tworzenie listy wymaganych aktualizacji... `r`n" 
 
$UpdateSearcher.ServerSelection = 3 #ssOthers

$UpdateSearcher.IncludePotentiallySupersededUpdates = $true # good for older OSes, to include Security-Only or superseded updates in the result list, otherwise these are pruned out and not returned as part of the final result list
 
$UpdateSearcher.ServiceID = $UpdateService.ServiceID.ToString() 
 
$SearchResult = $UpdateSearcher.Search("IsInstalled=0") # or "IsInstalled=0 or IsInstalled=1" to also list the installed updates as MBSA did
 
$Updates = $SearchResult.Updates 
 
if($Updates.Count -eq 0){ 
    Write-Output "Brak wymaganych aktualizacji. System jest aktualny." 
    return $null 
} 
 
$i = 0 
foreach($Update in $Updates){  
    Write-Output "$($i)> $($Update.Title)" >> "$rootDir\required_updates\required_updates_$(get-date -f yyyy-MM-dd-HH-mm).txt"
    $i++ 
}

Clear

Write-Host "Lista wymaganych aktualizacji zostala zapisana w katalogu:"
Write-Host "$rootDir\required_updates" -ForegroundColor White -BackgroundColor Red -NoNewline
Write-Host -ForegroundColor White -BackgroundColor Black
Write-Host 'Nacisnij dowolny przycisk, aby zamknac...' 
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');