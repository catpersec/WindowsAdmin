$logFullStatus = Get-WinEvent -ListLog Microsoft-Windows-PrintService/Operational -OutVariable PrinterLog
$logEnableStatus = $logFullStatus.IsEnabled




if ($logEnableStatus){
    Write-Host "ENABLED"
}
else {
    Write-Host "DISABLED"
}

