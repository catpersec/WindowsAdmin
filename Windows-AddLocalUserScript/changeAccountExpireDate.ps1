Write-Host "Skrypt sluzy do zmiany daty waznosci konta."
Read-Host "Aby kontynuowac nacisnij ENTER"
$username = Read-Host "Podaj nazwe uzytkownika"
Write-Host "Konfiguracja nowej daty wygasniecia konta"
$year = Read-Host "Podaj rok (liczba np. 2023)"
$month = Read-Host "Podaj miesiac (liczba 1 - 12)"
$day = Read-Host "Podaj dzien (liczba 1 - 31)"
$date = Get-Date -Year $year -Month $month -Day $day  -Hour "23" -Minute "59" -Second "59"
Set-LocalUser -Name $username -AccountExpires $date