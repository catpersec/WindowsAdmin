# Define variables
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$computerName = $ENV:COMPUTERNAME
$backupFolder = "C:\00_ADMIN\tempLogs\logsBackup_$computerName""_$timestamp"
$zipFileName = "logsBackup_$computerName$timestamp.zip"
$networkLocation = "C:\00_ADMIN\destLogs"



# Enable print log if disabled
$logFullStatus = Get-WinEvent -ListLog Microsoft-Windows-PrintService/Operational -OutVariable PrinterLog
$logEnableStatus = $logFullStatus.IsEnabled
if ($logEnableStatus){
}
else {
    $LogName = 'Microsoft-Windows-PrintService/Operational'
    wevtutil.exe sl $LogName /enabled:true
}



# Create backup folder if it doesn't exist
if (-not (Test-Path -Path $backupFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $backupFolder
}



# EXPORT
## Export Security, System, Application, Setup Windows logs to EVTX files
foreach ($logName in "Security", "System", "Application") {
    $evtxFileName = "$backupFolder\$logName-$timestamp.evtx"
    Get-WinEvent -LogName $logName | Export-Clixml $evtxFileName
}
## Export Print logs
$printLogFile = Get-ChildItem -Path "C:\Windows\System32\winevt\logs" -Filter "*printservice*operational*"
Copy-Item -Path $printLogFile -Destination "$backupFolder\printLog-$timestamp.evtx" -Force


# COMPRESS
## Compress EVTX files into a ZIP file
Compress-Archive -Path "$backupFolder\*.evtx" -DestinationPath "$backupFolder\$zipFileName"

# COPY
## Copy ZIP file to network location
Copy-Item -Path "$backupFolder\$zipFileName" -Destination $networkLocation -Force


#CLEAR
## Clear Security, System, Application, Logs
foreach ($logName in "Security", "System", "Application") {
    Clear-EventLog -LogName $logName
}
## Clear Print Logs
$LogName = 'Microsoft-Windows-PrintService/Operational'
wevtutil.exe cl $LogName

