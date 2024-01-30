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
    # Replace this with the actual function or command you want to run
    return "TESTOWY POZYTYW"
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



# LogActivity -computerName $computerName -isActive $isActive

