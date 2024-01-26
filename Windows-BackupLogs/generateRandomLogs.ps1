# Function to generate random events in Windows Event Logs
function Generate-RandomEvents {
    param (
        [string]$logName,
        [string]$source
    )

    $eventTypes = @( 'Error', 'Warning', 'Information', 'SuccessAudit', 'FailureAudit')

    # Register the event source if not already registered
    if (-not [System.Diagnostics.EventLog]::SourceExists($source)) {
        [System.Diagnostics.EventLog]::CreateEventSource($source, $logName)
    }

    for ($i = 1; $i -le 10; $i++) {
        $eventType = Get-Random -InputObject $eventTypes
        $eventID = Get-Random -Minimum 100 -Maximum 1000
        $message = "Random event number $i in $logName log."

        Write-EventLog -LogName $logName -Source $source -EventId $eventID -EntryType $eventType -Message $message
    }
}

# Generate random events in Application log
Generate-RandomEvents -logName 'Application' -source 'RandomEventGenerator'

# Generate random events in System log
Generate-RandomEvents -logName 'System' -source 'RandomEventGenerator'

# Generate random events in Security log
Generate-RandomEvents -logName 'Security' -source 'RandomEventGenerator'
