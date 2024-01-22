# Get the current date in a suitable format for filename suffix
$dateSuffix = Get-Date -Format "yyyyMMdd-HHmmss"

# Define the filename for the battery report with the date suffix
$reportFilename = "BatteryReport_$dateSuffix.html"

# Define report location

$reportLocation = "C:\0_ADMIN\batteryReports"

# Generate the battery report using powercfg
powercfg /batteryreport /output "$reportLocation\$reportFilename"

# Display a message with the generated filename
Write-Host "Battery report created: $reportFilename"
