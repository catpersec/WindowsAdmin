$LogName = 'Microsoft-Windows-PrintService/Operational'
wevtutil.exe sl $LogName /enabled:false
