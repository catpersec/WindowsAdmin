# # Define the path for the log file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFilePath = "C:\Users\catpersec\Documents\GitHub\WindowsAdmin\Windows-CheckClientActivityPerformFunction\logBackup-REPORT-$timestamp.txt"

function IsComputerActive {
    param (
        [string]$computerName
    )

    try {
        $IPv4Address = $computerName
        $PingObj = New-Object System.Net.NetworkInformation.Ping
                    
        $Timeout = 1000
        $Buffer = New-Object Byte[] 32

        $PingResult = $PingObj.Send($IPv4Address, $Timeout, $Buffer)

        if($PingResult.Status -eq "Success"){
            return $true
            break # Exit loop, if host is reachable
        }        
        else {
            return $false
        }
    } 
    catch {
        return $false
    }
}
    
function LogActivity {
    param (
        [string]$computerName,
        [bool]$isActive,
        [string]$logBackupResult
    )

    try {
        # Get the current date and time
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        # Determine the activity status
        $status = if ($isActive) { "active" } else { "inactive" }
        # Create log entry
        $logEntry = "$timestamp;[$computerName];$status;$logBackupResult"

        # Append log entry to the log file
        Add-Content -Path $logFilePath -Value $logEntry
    } catch {
        Write-Host "Error: $_"
    }
}


# Function to perform an action when the computer is active
function logBackup {
    param (
        [string]$logsNetworkLocation
    )
    # ZMIENNE
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $computerName = $ENV:COMPUTERNAME
    $backupFolder = "C:\00_ADMIN\localLogsBackup\logsBackup_$computerName-$timestamp"
    #$backupFolderMain = "C:\00_ADMIN\localLogsBackup"
    $zipFileName = "logsBackup_$computerName-$timestamp.zip"
    $networkLocation = $logsNetworkLocation

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

    $bodyLogList = $array -join ";"


    ## Skrypt czyscci logi lub w przypadku niezgodnej liczby logow - tworzy WARNING
    if ($logCount -eq 4){
        foreach ($logName in "Security", "System", "Application") {
            Clear-EventLog -LogName $logName
        }
        
        $LogName = 'Microsoft-Windows-PrintService/Operational'
        #wevtutil.exe cl $LogName
        return "Operacja polaczonego zgrywania i czyszczenia logow wykonana pomyslnie."
    }
    else
    {
        
        $warningToLog = "Liczba zarchiwizowanych logow nie wynosila 4. Logi NIE zostaly wyczyszczone. Tylko nastepujace logi zostaly zarchiwizowane i skopiowane na zasob sieciowy:[ $bodyLogList ] Przeprowadz identyfikacje problemu, a następnie manualnie wyczysc logi."
        return $warningToLog
    }


    # USUNIECIE PLIKOW EVTX
    ## Skrypt usuwa pliki *.EVTX z lokalnego folderu backupu logow.
    ## Plik *.ZIP ze zarchiwizowanymi logami pozostaje na dysku
    Get-ChildItem -Path $backupFolder | Where-Object Name -Match ".evtx" | ForEach-Object {
        Remove-Item -Path $_.FullName -Force
    }


}


function chooseHostFile {
    $txtFiles = Get-ChildItem -Path $PSScriptRoot -Filter *.txt

    # Check if any .txt files were found
    if ($txtFiles.Count -eq 0) {
        Write-Host "No .txt files found in the script directory."
    } else {
        # Display the list of .txt files
        Write-Host "Found .txt files in the script directory:"
        for ($i = 0; $i -lt $txtFiles.Count; $i++) {
            Write-Host "$($i + 1): $($txtFiles[$i].Name)"
        }

        # Prompt the user to choose a file by entering its number
        $fileNumber = Read-Host "Enter the number of the file you want to read"

        # Validate the user input
        if ($fileNumber -ge 1 -and $fileNumber -le $txtFiles.Count) {
            $chosenFile = $txtFiles[$fileNumber - 1].FullName
            Write-Host "You chose: $($chosenFile)"

            # Get content from the chosen file
            $fileContent = Get-Content -Path $chosenFile
            return $fileContent
        } else {
            Write-Host "Invalid input. Please enter a valid file number."
        }
    }
}

# Get the list of .txt files in the script directory

$hostFile = chooseHostFile
$logsNetworkLocation = Read-Host "Wprowadz lokalizacje sieciowa dla logow (np.: \\srv\logs): "

foreach ($x in $hostFile){
    $isActive = IsComputerActive -computerName $x
    
    if ($isActive) {
        $logBackupResult = logBackup
        LogActivity -computerName $pcName -isActive $isActive -logBackupResult $logBackupResult
    }
    if (-Not ($isActive)) {
        $logBackupResult = "Host nieosiagalny. Backup logow nie zostal wykonany."
        LogActivity -computerName $pcName -isActive $isActive -logBackupResult $logBackupResult
    }

}

function Foo ( $a,$b) {
    $a
    $b
    return "foo"
}

$x = "abc"
$y= 123

Invoke-Command -Credential $c -ComputerName $fqdn -ScriptBlock ${function:Foo} -ArgumentList $x,$y

# LogActivity -computerName $computerName -isActive $isActive

