$rootDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
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

Function createUsersFromCsv ($csvIteration) {
    process {
      try {
        $username = $csvIteration.userLogin
        $password = Read-Host "Podaj haslo tymczasowe dla uzytkownika $username (dla kazdego uzytkownika powinno byc inne!)" -AsSecureString
        $first_name = $csvIteration.firstName
        $last_name = $csvIteration.lastName
        $fullname = "$first_name $last_name"
        $description = $csvIteration.accountDescription
        $year = $csvIteration.accountExpireYear
        $month = $csvIteration.accountExpireMonth
        $day = $csvIteration.accountExpireDay
        $date = Get-Date -Year $year -Month $month -Day $day
        $usergroup = get-localgroup | Where-Object Description -match "przypadkowych ani celowych zmian na poziomie"  
        #$admingroup = Get-LocalGroup | Where-Object "Description" -match "Administratorzy mają pełny i nieograniczony dostęp"
        New-LocalUser -Name $username -Password $password -FullName $fullname -Description $description -AccountExpires $date -ErrorAction stop
        Write-Log -message "$username local user crated"

        # Add new user to administrator group
        Add-LocalGroupMember -Group $usergroup -Member $username -ErrorAction stop
        Write-Log -message "$username added to the local users group"

        $user = [ADSI]"WinNT://$env:ComputerName/$username,user"
        $user.PasswordExpired = 1
        $user.SetInfo()

        New-Item -Name "$username" -Path "G:\" -ItemType Directory -InformationAction SilentlyContinue
        New-Item -Name "$username" -Path "E:\" -ItemType Directory -InformationAction SilentlyContinue
		    New-Item -Name "$username" -Path "F:\" -ItemType Directory -InformationAction SilentlyContinue
     

      }catch{
        Write-log -message "Creating local account or adding to user group failed" -level "ERROR"
      }
    }    
}
     
Function aclset ($letter, $userLogin) {
  # Variables
  $FolderPath = "${letter}:\$userLogin"

  # Remove all permissions and inheritance from folder
  $acl = Get-Acl $FolderPath
  $acl.SetAccessRuleProtection($true,$false)
  $acl | Set-Acl $FolderPath



  # Add ACL for user
  $id = Get-LocalUser $userLogin
  $acl = Get-Acl $FolderPath
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($id,"Modify","Allow")
  $acl.SetAccessRule($AccessRule)
  $acl | Set-Acl $FolderPath   
}

Read-Host "Pamietaj o utworzeniu pliku usersCSV.csv na podstawie pliku usersXLSX.xlsx. Nacisnij ENTER aby kontynuowac"
Read-Host "Zmiana nazw kolumn spowoduje bledna dzialanie skryptu. Nacisnij ENTER aby kontynuowac"

Write-Log -message "#########"
Write-Log -message "$env:COMPUTERNAME - Create local user account"


$fullCSV = Import-Csv "$rootDir\usersCSV.csv" -Delimiter ";"
foreach ($x in $fullCSV){
  createUsersFromCsv $x
  aclset "G" $x.userLogin
  aclset "E" $x.userLogin
  aclset "F" $x.userLogin
}

Write-Log -message "#########"