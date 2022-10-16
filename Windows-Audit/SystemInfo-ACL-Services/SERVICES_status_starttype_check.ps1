$ErrorActionPreference = "Stop"
$Services = Import-Csv $PSScriptRoot\etc\SERVICES_items_sorted_by_pl_displayname.csv -Encoding utf8 -Delimiter ";"
#$Services = Get-Service | Select-Object Name,DisplayName,Status,StartType 

foreach ($Service in $Services){
    try{
        Get-Service $Service.Name | Select-Object DisplayName,StartType,Name,Status

    }
    catch{
        Write-Host $Service.Name -ForegroundColor Black -BackgroundColor Yellow -NoNewline
        Write-Host " -- " $Service.DisplayName "  " -ForegroundColor Black -BackgroundColor Yellow -NoNewline
        Write-Host "<< service does not exist in current Windows Version" -ForegroundColor Black -BackgroundColor Red -NoNewline
        Write-Host "" -ForegroundColor White -BackgroundColor Black
    }
    
}