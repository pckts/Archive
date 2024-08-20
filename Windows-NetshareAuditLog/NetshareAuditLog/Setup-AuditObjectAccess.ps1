Start-Transcript -Path 'C:\NetshareAuditLog\setup.log'
gpupdate /force
$localDrives = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" | Where-Object { $_.DeviceID -ne 'C:' } | ForEach-Object { $_.DeviceID.TrimEnd(":") }; $drives = Get-PSDrive -PSProvider 'FileSystem' | Where-Object { $_.Name -in $localDrives }
$rights = [System.Security.AccessControl.FileSystemRights]"FullControl" -bxor [System.Security.AccessControl.FileSystemRights]"ReadAttributes" -bxor [System.Security.AccessControl.FileSystemRights]"ReadExtendedAttributes" -bxor [System.Security.AccessControl.FileSystemRights]"ReadPermissions"
$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule('Everyone',$rights,'ContainerInherit, ObjectInherit','None','Success')
foreach ($drive in $drives) {Write-Host "Current drive: $($drive.Name)"; $directory = Get-Item -Path $drive.Root; $acl = Get-Acl -Path $directory.FullName -Audit; $acl.AddAuditRule($auditRule); Set-Acl -Path $directory.FullName -AclObject $acl}
schtasks /Delete /tn "NetshareAuditLogSetup" /f
Remove-Item -Path "C:\NetshareAuditLog\NetshareAuditLog.xml" -Force
Remove-Item -Path "C:\NetshareAuditLog\NetshareAuditLogSetup.xml" -Force
Remove-Item -Path "C:\NetshareAuditLog\Setup-AuditObjectAccess.ps1" -Force
Remove-Item -Path "C:\NetshareAuditLog\Installer.ps1" -Force
Remove-Item -Path "C:\NetshareAuditLog\Install.bat" -Force
New-Item -ItemType directory -Path "C:\NetshareAuditLog\LogArchive"
Stop-transcript