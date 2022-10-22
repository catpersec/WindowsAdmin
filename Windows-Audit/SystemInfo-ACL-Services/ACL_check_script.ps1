$exek = Get-Content $PSScriptRoot\etc\ACL_items_to_check.txt

#checks System32 folder
Write-Host ""
Write-Host "System32 check------------------------------------------------------------------------" -ForegroundColor Black -BackgroundColor White
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Black -BackgroundColor White
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Black -BackgroundColor White
Foreach ($exe in $exek){
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    Write-Host "EXE:`t" $exe -ForegroundColor Black -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    $acls = (Get-Acl C:\Windows\System32\$exe).Access | Select-Object FileSystemRights,AccessControlType,IdentityReference
    Foreach ($acl in $acls){

        $myObject = [PSCustomObject]@{
            FileSystemRights = $acl.FileSystemRights
            AccessControlType = $acl.AccessControlType
            IdentityReference = $acl.IdentityReference
        }
        
        
        $measure = $myObject.FileSystemRights
        $measure = Out-String -InputObject $measure
        $charCount = ($measure.ToCharArray() | Where-Object {$_ -eq ','} | Measure-Object).Count
        
        $tab = ""
        if ($charCount -eq 1){
            $tab = "`t"
        }
        if ($charCount -eq 0){
            $tab = "`t`t`t"
        }
        $objfilesysrigh


        if ($myObject.IdentityReference -match "System" -Or $myObject.IdentityReference -match "trusted" -Or $myObject.IdentityReference -match "admin") {
            Write-Host "File System Rights: " $myObject.FileSystemRights -NoNewline
            Write-Host $tab "ACL: " $myObject.AccessControlType -NoNewline
            Write-Host "`tIdentity Reference: " $myObject.IdentityReference
        }
        elseif ($myObject.IdentityReference -match "reade" -Or $myObject.IdentityReference -match "czytel") {
            Write-Host "File System Rights: " $myObject.FileSystemRights -ForegroundColor Black -BackgroundColor Yellow -NoNewline
            Write-Host $tab "ACL: " $myObject.AccessControlType -ForegroundColor Black -BackgroundColor Yellow -NoNewline
            Write-Host "`tIdentity Reference: " $myObject.IdentityReference -ForegroundColor Black -BackgroundColor Yellow -NoNewline
            Write-Host "" -ForegroundColor White -BackgroundColor Black
        }
        else{
            Write-Host "File System Rights: " $myObject.FileSystemRights -ForegroundColor Black -BackgroundColor Red -NoNewline
            Write-Host $tab "ACL: " $myObject.AccessControlType -ForegroundColor Black -BackgroundColor Red -NoNewline
            Write-Host "`tIdentity Reference: " $myObject.IdentityReference -ForegroundColor Black -BackgroundColor Red -NoNewline
            Write-Host "" -ForegroundColor White -BackgroundColor Black
        }
    }
}

#checks SysWOW64 folder
Write-Host ""
Write-Host "SysWOW64 check------------------------------------------------------------------------" -ForegroundColor Black -BackgroundColor White
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Black -BackgroundColor White
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Black -BackgroundColor White

Foreach ($exe in $exek){
    Write-Host ""
    Write-Host "EXE:`t" $exe -ForegroundColor Black -BackgroundColor Yellow -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
    $acls = (Get-Acl C:\Windows\SysWOW64\$exe).Access | Select-Object FileSystemRights,AccessControlType,IdentityReference
    Foreach ($acl in $acls){

        $myObject = [PSCustomObject]@{
            FileSystemRights = $acl.FileSystemRights
            AccessControlType = $acl.AccessControlType
            IdentityReference = $acl.IdentityReference
        }
        
        
        $measure = $myObject.FileSystemRights
        $measure = Out-String -InputObject $measure
        $charCount = ($measure.ToCharArray() | Where-Object {$_ -eq ','} | Measure-Object).Count
        
        $tab = ""
        if ($charCount -eq 1){
            $tab = "`t"
        }
        elseif ($charCount -eq 0){
            $tab = "`t`t`t"
        }
        $objfilesysrigh


        if ($myObject.IdentityReference -match "System" -Or $myObject.IdentityReference -match "trusted" -Or $myObject.IdentityReference -match "admin") {
            Write-Host "File System Rights: " $myObject.FileSystemRights -NoNewline
            Write-Host $tab "ACL: " $myObject.AccessControlType -NoNewline
            Write-Host "`tIdentity Reference: " $myObject.IdentityReference
        }
        elseif ($myObject.IdentityReference -match "reade" -Or $myObject.IdentityReference -match "czytel") {
            Write-Host "File System Rights: " $myObject.FileSystemRights -ForegroundColor Black -BackgroundColor Yellow -NoNewline
            Write-Host $tab "ACL: " $myObject.AccessControlType -ForegroundColor Black -BackgroundColor Yellow -NoNewline
            Write-Host "`tIdentity Reference: " $myObject.IdentityReference -ForegroundColor Black -BackgroundColor Yellow -NoNewline
            Write-Host "" -ForegroundColor White -BackgroundColor Black
        }
        else{
            Write-Host "File System Rights: " $myObject.FileSystemRights -ForegroundColor Black -BackgroundColor Red -NoNewline
            Write-Host $tab "ACL: " $myObject.AccessControlType -ForegroundColor Black -BackgroundColor Red -NoNewline
            Write-Host "`tIdentity Reference: " $myObject.IdentityReference -ForegroundColor Black -BackgroundColor Red -NoNewline
            Write-Host "" -ForegroundColor White -BackgroundColor Black
        }
    }
}
