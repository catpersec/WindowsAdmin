# ZMIENNE
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$computerName = $ENV:COMPUTERNAME
$backupFolder = "C:\00_ADMIN\localLogsBackup\logsBackup_$computerName-$timestamp"
$backupFolderMain = "C:\00_ADMIN\localLogsBackup"
$zipFileName = "logsBackup_$computerName-$timestamp.zip"
$networkLocation = "\\WIN11-VM\destLogs"

# # NETWORK SHARE CHECK

# # Check if the network share is accessible
# if (Test-Path $networkLocation) {
#     Write-Host "SMB network share ($networkLocation) is accessible."
# } else {
#     Write-Host "SMB network share ($networkLocation) is not accessible."
# }


# PRINT LOG ENABLE
## Skrypt wlacza domyslnie wylaczony dziennik zdarzeń Drukowania
$logFullStatus = Get-WinEvent -ListLog Microsoft-Windows-PrintService/Operational -OutVariable PrinterLog
$logEnableStatus = $logFullStatus.IsEnabled
if ($logEnableStatus){
}
else {
    $LogName = 'Microsoft-Windows-PrintService/Operational'
    wevtutil.exe sl $LogName /enabled:true
}



# LOCAL LOG FOLDER 
## Skrypt stworzy lokalny folder na backup logow jesli taki nie istnieje 
if (-not (Test-Path -Path $backupFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $backupFolder
}



# BACKUP LOGOW
## Export Security, System, Application, Setup Windows logs to EVTX files
foreach ($logName in "Security", "System", "Application") {
    $evtxFileName = "$backupFolder\$logName-$timestamp.evtx"
    wevtutil /epl $evtxFileName
    # Get-WinEvent -LogName $logName | Export-Clixml $evtxFileName
}
## Export Print logs
$printLogFile = Get-ChildItem -Path "C:\Windows\System32\winevt\logs" -Filter "*printservice*operational*"
Copy-Item -Path $printLogFile -Destination "$backupFolder\printLog-$timestamp.evtx" -Force



# KOMPRESOWANIE LOGOW
## Skrypt kompresuje pliki *.evtx do archiwum ZIP
Compress-Archive -Path "$backupFolder\*.evtx" -DestinationPath "$backupFolder\$zipFileName"



# KOPIA LOGOW NA ZASOB SIECIOWY
## Skrypt skopiuje plik ZIP na zdefiniowany w zmiennych zasob sieciowy
Copy-Item -Path "$backupFolder\$zipFileName" -Destination $networkLocation -Force



# CZYSZCZENIE LOGOW
## SAFETY CHECK - sprawdza czy liczba zbackupowanych logow wynosi 4 - jeżeli nie, to czyszczenie nie zostanie przeprowadzone
$logCount = (Get-ChildItem $backupFolder | Where-Object Name -Match ".evtx" | Measure-Object ).Count;

$logList = Get-ChildItem $backupFolder | Where-Object Name -Match ".evtx" | Select-Object Name
$array = @()

foreach ($log in $logList){
    $name = $log.Name
    $array += "$name"
}

$bodyLogList = $array -join "`n"


## Skrypt czyscci logi lub w przypadku niezgodnej liczby logow - tworzy WARNING
if ($logCount -eq 4){
    foreach ($logName in "Security", "System", "Application") {
        Clear-EventLog -LogName $logName
    }
    
    $LogName = 'Microsoft-Windows-PrintService/Operational'
    wevtutil.exe cl $LogName
}
else
{
    # Tworzenie WARNINGU
    $warningFileName = "WARNING-LOG-BACKUP_$computerName-$timestamp-.txt"
    $fileContent = @"
    Liczba zarchiwizowanych logow nie wynosila 4.
    Logi NIE zostaly wyczyszczone.
    
    Tylko ponizsze logi zostaly zarchiwizowane i skopiowane na zasob sieciowy:
    $bodyLogList  
    
    Przeprowadz identyfikacje problemu, a następnie manualnie wyczysc logi.
"@

    $filePath = Join-Path -Path $backupFolderMain -ChildPath $warningFileName
    Set-Content -Path $filePath -Value $fileContent
    ## Skopiowanie WARNINGU na zasob sieciowy
    Copy-Item -Path "$backupFolderMain\$warningFileName" -Destination $networkLocation -Force

}




# USUNIECIE PLIKOW EVTX
## Skrypt usuwa pliki *.EVTX z lokalnego folderu backupu logow.
## Plik *.ZIP ze zarchiwizowanymi logami pozostaje na dysku
Get-ChildItem -Path $backupFolder | Where-Object Name -Match ".evtx" | ForEach-Object {
    Remove-Item -Path $_.FullName -Force
}

