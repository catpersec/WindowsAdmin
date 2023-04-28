

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
$admingroup = Get-LocalGroup | Where-Object "Description" -match "Administratorzy mają pełny i nieograniczony dostęp"

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
        Write-Log -message "$username local user crated"

        # Add new user to administrator group
        Add-LocalGroupMember -Group $usergroup -Member $username -ErrorAction stop
        Write-Log -message "$username added to the local users group"

        $user = [ADSI]"WinNT://$env:ComputerName/$username,user"
        $user.PasswordExpired = 1
        $user.SetInfo()

        New-Item -Name "$username" -Path "G:\" -ItemType Directory
        New-Item -Name "$username" -Path "E:\" -ItemType Directory
		New-Item -Name "$username" -Path "F:\" -ItemType Directory
     

      }catch{
        Write-log -message "Creating local account or adding to user group failed" -level "ERROR"
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
Write-Log -message "$env:COMPUTERNAME - Create local user account"

Create-LocalUser
aclset "G"
aclset "E"
aclset "F"


Write-Log -message "#########"