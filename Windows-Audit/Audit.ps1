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
    # Zainstalowany soft
    Write-Host "[CHECK] Zainstalowane oprogramowanie:`t" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black

    if (!([Diagnostics.Process]::GetCurrentProcess().Path -match '\\syswow64\\'))
    {
    $unistallPath = "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
    $unistallWow6432Path = "\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
    @(
    if (Test-Path "HKLM:$unistallWow6432Path" ) { Get-ChildItem "HKLM:$unistallWow6432Path"}
    if (Test-Path "HKLM:$unistallPath" ) { Get-ChildItem "HKLM:$unistallPath" }
    if (Test-Path "HKCU:$unistallWow6432Path") { Get-ChildItem "HKCU:$unistallWow6432Path"}
    if (Test-Path "HKCU:$unistallPath" ) { Get-ChildItem "HKCU:$unistallPath" }
    ) |
    ForEach-Object { Get-ItemProperty $_.PSPath } |
    Where-Object {
        $_.DisplayName -and !$_.SystemComponent -and !$_.ReleaseType -and !$_.ParentKeyName -and ($_.UninstallString -or $_.NoRemove)
    } |
    Sort-Object DisplayName|
    Select-Object DisplayName,DisplayVersion | out-host
    }
    else
    {
    "You are running 32-bit Powershell on 64-bit system. Please run 64-bit Powershell instead." | Write-Host -ForegroundColor Red
    }
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host

    # DATA INSTALACJI SYSTEMU
    Write-Host "[CHECK] Data instalacji systemu operacyjnego:" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Write-Host $install_date | out-host
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host

    # WERSJA SYSTEMU
    Write-Host "[CHECK] Sprawdzenie Wersji systemu" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Write-Host "[WYKONAJ RECZNIE] Sprawdzenie wersji systemu Windows - sprawdz na nowo-otwartym okienku" -ForegroundColor White -BackgroundColor Red
    winver
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host

    # DYSKI
    Write-Host "[CHECK] Lista dyskow + formatowanie partycji:`t" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Get-WmiObject -Class Win32_LogicalDisk  | select DeviceID, DriveType, FileSystem, VolumeSerialNumber, VolumeName |ft -autosize | out-host
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host

    # AKTYWACJA SYSTEMU
    Write-Host "[CHECK] Sprawdzenie aktywacji systemu" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Write-Host "[!]" -ForegroundColor White -BackgroundColor Red -NoNewline | out-host
    Write-Host "[WYKONAJ RECZNIE] Sprawdzenie aktywacji - sprawdz na nowo-otwartym okienku"
    slmgr /xpr
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host

    # KONTA LOKALNE W SYSTEMIE
    Write-Host "[CHECK] Sprawdzenie kont lokalnych w systemie" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Get-LocalUser | ft -AutoSize | out-host
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host
    
    # GRUPY 
    Write-Host "[CHECK] Sprawdzenie grup systemie (w kolejnym sprawdzeniu wyswietlone zostana listy uztykownikow w poszczegolnych grupach" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Write-Host "[!]" -ForegroundColor White -BackgroundColor Red -NoNewline | out-host
    Write-Host "(w kolejnym sprawdzeniu wyswietlone zostana listy uztykownikow w poszczegolnych grupach" -ForegroundColor White -BackgroundColor Black
    Get-LocalGroup | Format-Table -AutoSize | out-host
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host

    #UZYTKOWNICY W GRUPACH
    Write-Host "[CHECK] Sprawdzenie uzytkownikow w grupach" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Foreach ($group in $groups){
        $group_name = $group.Name
        $groupmembership = Get-LocalGroupMember $group
        
        if ($groupmembership) {
            #Write-Host "_________________________________________________________________"
            Write-Host "Grupa: " -ForegroundColor White -BackgroundColor Black -NoNewline
            Write-Host $group_name -ForegroundColor Black -BackgroundColor Yellow -NoNewline
            Write-Host "" -ForegroundColor White -BackgroundColor Black | out-host
            # Write-Host "" -ForegroundColor White -BackgroundColor Black | out-host
            # Write-Host ">> Uzytkownicy w grupie: $group_name" -ForegroundColor White -BackgroundColor DarkCyan -NoNewline | out-host
            #$groupmembership | Format-Table -AutoSize | out-host

            Write-Host ""
            Write-Host "Typ |`tUzytkownik"
            Write-Host "--- |`t----------"
            foreach ($member in $groupmembership){
                Write-Host $member.ObjectClass "`t" $member.name 
            }
            Write-Host ""


        }
        else {
            #Write-Host "_________________________________________________________________"
            Write-Host "Grupa: " -ForegroundColor White -BackgroundColor Black -NoNewline
            Write-Host $group_name -ForegroundColor Black -BackgroundColor Yellow -NoNewline
            Write-Host "" -ForegroundColor White -BackgroundColor Black | out-host
            Write-Host "[!]" -ForegroundColor White -BackgroundColor Red -NoNewline | out-host
            Write-Host " Brak uzytkownikow w grupie: $group_name" -NoNewline
            Write-Host "" -ForegroundColor White -BackgroundColor Black | out-host
            Write-Host "" -ForegroundColor White -BackgroundColor Black | out-host
            # Write-Host "" -ForegroundColor White -BackgroundColor Black | out-host

        }    
    }
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host

    # SPRAWDZENIE UAC
    Write-Host "[CHECK] Sprawdzenie UAC - powinno byc 'Always notify'" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Write-Host "Aktualny status:" -ForegroundColor White -BackgroundColor Red -NoNewline
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
        "NotIfy me only when appsf try to make changes to my computer(default)" 
    } 
    ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 2 -And $PromptOnSecureDesktop_Value -Eq 1){ 
        "Always notify" 
    } 
    Else{ 
        "Unknown" 
    }
    # Write-Host "\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/" -ForegroundColor White -BackgroundColor Red -NoNewline
    # Write-Host "" -ForegroundColor White -BackgroundColor Black
    Write-Host ""
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host

    # SPRAWDZENIE ACL
    Write-Host "[CHECK] Nacisnij ENTER aby uruchomic skrypt sprawdzajacy dostep do plikow w System32 i SysWOW64" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black | out-host
    Write-Host "" -ForegroundColor White -BackgroundColor Black | out-host
    & "$rootDir\SystemInfo-ACL-Services\ACL_check_script.ps1" | out-host
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host

    # SPRAWDZNIE USLUG
    Write-Host "" -ForegroundColor White -BackgroundColor Black | out-host
    Write-Host "[CHECK] Nacisnij ENTER aby uruchomic skrypt sprawdzajacy status uslug windows" -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black | out-host
    & "$rootDir\SystemInfo-ACL-Services\SERVICES_status_starttype_check.ps1" | out-host
    Write-Host "" | out-host
    Read-Host "Aby kontynuwac nacisnij ENTER"
    Clear-Host
}

basic

# RUN/DONT RUN POLICY ANALYZER
$run_lgpo_check = [System.Windows.MessageBox]::Show('Sprawdzanie LGPO realizowane jest przy pomocy oprogramowania Microsoft Policy Analyzer. Instrukcja uzycia znajduje sie w pliku README. Czy chcesz teraz uruchomic Policy Analyzer?','LGPO','YesNo')
if ($run_lgpo_check -eq "Yes") {
    & "$rootDir\LGPO\PolicyAnalyzer.exe"
}
# else {
#     continue
# }
# RUN/DONT RUN UPDATE CHECK
$run_update_check = [System.Windows.MessageBox]::Show('Czy chcesz teraz uruchomic skrypt do sprawdzenia aktualizacji? Jesli tak, przygotuj plik wsusscn2.cab.','Update','YesNo')
if ($run_update_check -eq "Yes") {
    & "$rootDir\OfflineUpdate\scan_required_updates.ps1"
}

# else{
#     exit
# }