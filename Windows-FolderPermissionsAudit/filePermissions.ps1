$timestamp = (Get-Date).toString("yyyy-MM-dd-HH-mm")
$timestamp2 = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")

$auditLocation = Read-Host "Wprowadz sciezke gdzie przeprowadzony bedzie audyt uprawnien do folderow (np.: F:\)"
$OutFile = "C:\log\permissionsReport $timestamp.csv"
$Header = "Folder Path,IdentityReference,AccessControlType,IsInherited,InheritanceFlags,PropagationFlags"
Add-Content -Value $Header -Path $OutFile

$RootPath = $auditLocation

$Folders = Get-ChildItem $RootPath | where {$_.psiscontainer -eq $true}

foreach ($Folder in $Folders){
    $ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access }

Foreach ($ACL in $ACLs){
    $OutInfo = $Folder.Fullname + "," + $ACL.IdentityReference + "," + $ACL.AccessControlType + "," + $ACL.IsInherited + "," + $ACL.InheritanceFlags + "," + $ACL.PropagationFlags
    Add-Content -Value $OutInfo -Path $OutFile
}}

Add-Content -Value "Audit directory: $auditLocation. Audit performed $timestamp2" -Path $OutFile