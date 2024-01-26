# Function to generate random events in Windows Event Logs
function Generate-RandomEvents {
    param (
        [string]$logName,
        [string]$source
    )

    $eventTypes = @( 'Error', 'Warning', 'Information', 'SuccessAudit', 'FailureAudit')

    for ($i = 1; $i -le 10; $i++) {
        $eventType = Get-Random -InputObject $eventTypes
        $eventID = Get-Random -Minimum 100 -Maximum 1000
        $message = "Random event number $i in $logName log."

        Write-EventLog -LogName $logName -Source $source -EventId $eventID -EntryType $eventType -Message $message
    }
}

# Generate random events in Application log
Generate-RandomEvents -logName 'Application' -source 'RandomEventGenerator'

