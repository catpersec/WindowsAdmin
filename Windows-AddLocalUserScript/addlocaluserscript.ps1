<#
.SYNOPSIS
  Create local admin acc

.DESCRIPTION
  Creates a local administrator account on de computer. Requires RunAs permissions to run

.OUTPUTS
  none

.NOTES
  Version:        1.0
  Author:         R. Mens - LazyAdmin.nl
  Creation Date:  25 march 2022
  Purpose/Change: Initial script development
#>

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
        Write-Log -message "$username local user crated"

        # Add new user to administrator group
        Add-LocalGroupMember -Group $usergroup -Member $username -ErrorAction stop
        Write-Log -message "$username added to the local users group"

        $user = [ADSI]"WinNT://$env:ComputerName/$username,user"
        $user.PasswordExpired = 1
        $user.SetInfo()

      }catch{
        Write-log -message "Creating local account or adding to user group failed" -level "ERROR"
      }
    }    
}

Write-Log -message "#########"
Write-Log -message "$env:COMPUTERNAME - Create local user account"

Create-LocalUser

Write-Log -message "#########"

