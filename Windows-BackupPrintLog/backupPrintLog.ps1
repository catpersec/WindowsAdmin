$networkLocation = Read-Host "Lokalizacja sieciowa dla logow: "

$scriptBlock = {
# VARIABLES
    $date = Get-Date -Format "yyyyMMdd-HHmmss"
    $computerName = $env:COMPUTERNAME
    param ($networkLocationPassed)

    # Step 1: Create a temporary folder
    $tempFolder = New-Item -ItemType Directory -Path (Join-Path -Path $env:TEMP -ChildPath "printLogFolder-$computerName-$date")

    # Step 2: Copy item to the temp folder
    $printLogFile = Get-ChildItem -Path "C:\Windows\System32\winevt\logs" -Filter "*printservice*operational*"
    Copy-Item -Path $printLogFile -Destination "$tempFolder\printLog-$date.evtx" -Force

    # Step 3: Archive the whole folder
    $zipFile = "$tempFolder.zip"
    Compress-Archive -Path $tempFolder -DestinationPath $zipFile

    # Step 4: Copy the archive to a network location (replace 'networkLocation' with the desired network location)
    $networkLocation = $networkLocationPassed
    Copy-Item -Path $zipFile -Destination $networkLocation -Force

    # Step 5: Remove temporary folder and zip file in the source location
    Remove-Item -Path $tempFolder -Force -Recurse
    Remove-Item -Path $zipFile -Force
}

$pcList = Get-Content .\pcList.txt

Invoke-Command $pcList -ScriptBlock $scriptBlock -ArgumentList $networkLocation
