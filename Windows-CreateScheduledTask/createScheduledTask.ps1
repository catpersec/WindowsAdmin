# Content of CreateScheduledTask.ps1
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\Users\catpersec\Documents\GitHub\WindowsAdmin\Windows-ScheduledBatteryReport\scheduledBatteryReport.ps1"'
$trigger = New-ScheduledTaskTrigger -Daily -At "7:00 PM"  # Change the time as needed

# Replace "YourTaskName" with the desired task name
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "customCreateBatteryReport" -Force