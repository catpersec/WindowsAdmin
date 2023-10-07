$testName = "comp-name"
$date = Get-Date -Format "yyyyMMdd-HHmmss"
$printLog = Get-ChildItem -Path "C:\Windows\System32\winevt\logs" -Filter "*printservice*operational*"
Copy-Item $printLog -Destination "C:\test\printLog-$testName-$date.evtx"