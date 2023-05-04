

# Configuration
$username = Read-Host "Podaj nazwe uzytkownika"
$password = Read-Host -AsSecureString "Podaj tymczasowe haslo uzytkownika. Zmiana zostanie wymuszona przy pierwszym logowaniu."
$first_name = Read-Host "Podaj imie uzytkownika"
$last_name = Read-Host "Podaj nazwisko uzytkownika"
$fullname = "$first_name $last_name"
$description = Read-Host "Opis dla konta"
Write-Host "Data wygasniecia konta"
$year = Read-Host "Podaj rok"
$month = Read-Host "Podaj miesiac"
$day = Read-Host "Podaj dzien"
$date = Get-Date -Year $year -Month $month -Day $day
$usergroup = get-localgroup | Where-Object Description -match "przypadkowych ani celowych zmian na poziomie"  

#$password = ConvertTo-SecureString "LazyAdminPwd123!" -AsPlainText -Force  # Super strong plane text password here (yes this isn't secure at all)
$logFile = "C:\log\log.txt"

Function Write-Log {
  param(
      [Parameter(Mandatory = $true)][string] $message,
      [Parameter(Mandatory = $false)]
      [ValidateSet("INFO","WARN","ERROR")]
      [string] $level = "INFO"
  )
  # Create timestamp
  $timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")

  # Append content to log file
  Add-Content -Path $logFile -Value "$timestamp [$level] - $message"
}

Function Create-LocalUser {
    process {
      try {
        New-LocalUser "$username" -Password $password -FullName $fullname -Description $description -AccountExpires $date -ErrorAction stop
        Write-Log -message "$username uzytkownik lokalny utworzony"

        # Add new user to administrator group
        Add-LocalGroupMember -Group $usergroup -Member $username -ErrorAction stop
        Write-Log -message "$username dodany do lokalnej grupu Uzytkownicy"

        $user = [ADSI]"WinNT://$env:ComputerName/$username,user"
        $user.PasswordExpired = 1
        $user.SetInfo()

        New-Item -Name "$username" -Path "G:\" -ItemType Directory
        New-Item -Name "$username" -Path "E:\" -ItemType Directory
		    New-Item -Name "$username" -Path "F:\" -ItemType Directory
     

      }catch{
        Write-log -message "Wystapil blad przy tworzeniu uzytkownika / dodawaniu do grupy lokalnej / tworzeniu katalogow." -level "ERROR"
      }
    }    
}

Function aclset ($letter) {
  # Variables
  $FolderPath = "${letter}:\$username"

  # Remove all permissions and inheritance from folder
  $acl = Get-Acl $FolderPath
  $acl.SetAccessRuleProtection($true,$false)
  $acl | Set-Acl $FolderPath

  # Add ACL for user
  $id = Get-LocalUser $username
  $acl = Get-Acl $FolderPath
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($id,"Modify","Allow")
  $acl.SetAccessRule($AccessRule)
  $acl | Set-Acl $FolderPath   
}

Write-Log -message "#########"
Write-Log -message "$env:UserName - Administrator wykonujacy"
Write-Log -message "$env:COMPUTERNAME - Utworzenie uzytkownika"

Create-LocalUser
aclset "G"
aclset "E"
aclset "F"


Write-Log -message "#########"

