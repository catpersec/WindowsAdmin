$OutFile = "[location_where_permissionsReport.csv_will_be_saved]\permissionsReport.csv"
$Header = "Folder Path,IdentityReference,AccessControlType,IsInherited,InheritanceFlags,PropagationFlags"
Del $OutFile
Add-Content -Value $Header -Path $OutFile

$RootPath = "[location]"

$Folders = Get-ChildItem $RootPath | where {$_.psiscontainer -eq $true}

foreach ($Folder in $Folders){
$ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access }
Foreach ($ACL in $ACLs){
$OutInfo = $Folder.Fullname + "," + $ACL.IdentityReference + "," + $ACL.AccessControlType + "," + $ACL.IsInherited + "," + $ACL.InheritanceFlags + "," + $ACL.PropagationFlags
Add-Content -Value $OutInfo -Path $OutFile
}}