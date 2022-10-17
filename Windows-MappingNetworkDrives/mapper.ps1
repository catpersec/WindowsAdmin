$rootDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

$Computers = get-content "$rootDir\hosts.txt"

$value = Get-Content "$rootDir\mapper.vbs" -Raw

Invoke-Command -ComputerName $Computers -ScriptBlock{

	New-Item -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp' -Name "mapper.vbs" -ItemType "file" -Value $using:value -Force
	
} -ThrottleLimit 50
