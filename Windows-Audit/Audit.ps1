$Host.UI.RawUI.BackgroundColor = ($bckgrnd = 'Black')
$Host.UI.RawUI.ForegroundColor = 'White'
Clear-Host

$install_date = ([WMI]'').ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).InstallDate)
$groups = Get-LocalGroup
$rootDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

Add-Type -AssemblyName PresentationFramework

Function Get-RegistryValue($key, $value){
    (Get-ItemProperty $key $value).$value
}

function basic {
    ###SCRIPT
    # DATA INSTALACJI SYSTEMU
    Write-Host "[CHECK] Data instalacji systemu operacyjnego:`t" -ForegroundColor Black -BackgroundColor Green
    Write-Host $install_date 
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"

    # WERSJA SYSTEMU
    Write-Host "[CHECK] Sprawdzenie Wersji systemu" -ForegroundColor Black -BackgroundColor Green
    Write-Host "[WYKONAJ RECZNIE] Sprawdzenie wersji systemu Windows - sprawdz na nowo-otwartym okienku" -ForegroundColor White -BackgroundColor Red
    winver
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"

    # DYSKI
    Write-Host "[CHECK] Lista dyskow + formatowanie partycji:`t" -ForegroundColor Black -BackgroundColor Green
    Get-WmiObject -Class Win32_LogicalDisk  | select DeviceID, DriveType, FileSystem, VolumeSerialNumber, VolumeName |ft -autosize
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"

    # AKTYWACJA SYSTEMU
    Write-Host "[CHECK] Sprawdzenie aktywacji systemu" -ForegroundColor Black -BackgroundColor Green
    Write-Host "[WYKONAJ RECZNIE] Sprawdzenie aktywacji - sprawdz na nowo-otwartym okienku" -ForegroundColor White -BackgroundColor Red
    slmgr /xpr
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Read-Host "Aby kontynuwac nacisnij ENTER"

    # KONTA LOKALNE W SYSTEMIE
    Write-Host "[CHECK] Sprawdzenie kont lokalnych w systemie" -ForegroundColor Black -BackgroundColor Green
    Get-LocalUser | ft -AutoSize
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"

    # GRUPY 
    Write-Host "[CHECK] Sprawdzenie grup systemie (w kolejnym sprawdzeniu wyswietlone zostana listy uztykownikow w poszczegolnych grupach" -ForegroundColor Black -BackgroundColor Green
    Get-LocalGroup | Format-Table -AutoSize
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"

    #UZYTKOWNICY W GRUPACH
    Write-Host "[CHECK] Sprawdzenie uzytkownikow w grupach" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Foreach ($group in $groups){
        $group_name = $group.Name
        $groupmembership = Get-LocalGroupMember $group
        
        if ($groupmembership) {
            Write-Host "" -ForegroundColor White -BackgroundColor Black
            Write-Host "    >> Uzytkownicy w grupie: $group_name" -ForegroundColor White -BackgroundColor DarkCyan -NoNewline
            Write-Host "" -ForegroundColor White -BackgroundColor Black
            $groupmembership | Format-Table -AutoSize
        }
        else {
            Write-Host "    >> Brak uzytkownikow w grupie: $group_name" -ForegroundColor Black -BackgroundColor Yellow -NoNewline
            Write-Host "" -ForegroundColor White -BackgroundColor Black
        }    
    }
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"

    # SPRAWDZENIE UAC
    Write-Host "[CHECK] Sprawdzenie UAC - powinno byc 'Always notify'" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Write-Host "\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/" -ForegroundColor White -BackgroundColor Red -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    $Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 
    $ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin" 
    $PromptOnSecureDesktop_Name = "PromptOnSecureDesktop" 

    $ConsentPromptBehaviorAdmin_Value = Get-RegistryValue $Key $ConsentPromptBehaviorAdmin_Name 
    $PromptOnSecureDesktop_Value = Get-RegistryValue $Key $PromptOnSecureDesktop_Name 

    If($ConsentPromptBehaviorAdmin_Value -Eq 0 -And $PromptOnSecureDesktop_Value -Eq 0){ 
        "Never notIfy" 
    } 
    ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 0){ 
        "NotIfy me only when apps try to make changes to my computer(do not dim my desktop)" 
    } 
    ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 1){ 
        "NotIfy me only when apps try to make changes to my computer(default)" 
    } 
    ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 2 -And $PromptOnSecureDesktop_Value -Eq 1){ 
        "Always notify" 
    } 
    Else{ 
        "Unknown" 
    }
    Write-Host "\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/" -ForegroundColor White -BackgroundColor Red -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Read-Host "Aby kontynuwac nacisnij ENTER"


    # SPRAWDZENIE ACL
    Write-Host "[CHECK] Nacisnij ENTER aby uruchomic skrypt sprawdzajacy dostep do plikow w System32 i SysWOW64" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Read-Host "Po zatrzymaniu skryptu nacisnij ENTER jeszcze raz!"
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    & "$rootDir\SystemInfo-ACL-Services\ACL_check_script.ps1"

    # SPRAWDZNIE USLUG
    Write-Host "[CHECK] Nacisnij ENTER aby uruchomic skrypt sprawdzajacy status uslug windows" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Read-Host "Po zatrzymaniu skryptu nacisnij ENTER jeszcze raz!"
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    & "$rootDir\SystemInfo-ACL-Services\SERVICES_status_starttype_check.ps1"
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Read-Host "Aby kontynuwac nacisnij ENTER"
}

basic

# RUN/DONT RUN POLICY ANALYZER
$run_lgpo_check = [System.Windows.MessageBox]::Show('Sprawdzanie LGPO realizowane jest przy pomocy oprogramowania Microsoft Policy Analyzer. Instrukcja uzycia znajduje sie w pliku README. Czy chcesz teraz uruchomic Policy Analyzer?','LGPO','YesNo')
if ($run_lgpo_check -eq "Yes") {
    & "$rootDir\LGPO\PolicyAnalyzer.exe"
}
else {
    continue
}
# RUN/DONT RUN UPDATE CHECK
$run_update_check = [System.Windows.MessageBox]::Show('Czy chcesz teraz uruchomic skrypt do sprawdzenia aktualizacji? Jesli tak, przygotuj plik wsusscn2.cab.','Update','YesNo')
if ($run_update_check -eq "Yes") {
    & "$rootDir\OfflineUpdate\scan_required_updates.ps1"
}

else{
    exit
}