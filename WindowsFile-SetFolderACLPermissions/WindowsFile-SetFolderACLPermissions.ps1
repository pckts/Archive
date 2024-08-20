# Re-usable function for setting the same user or group permissions on multiple identically named folders
# Can be used as-is or rewritten to fit a specific usecase.

# Usage example:
# Set-ACLPermissions WORKGROUP\packet FullControl Allow D:\Dev\Projects Code
# This example gives the user WORKGROUP\packet the FullControl permissions on all folders called "Code" within the D:\Dev\Projects folder and all subfolders

#Note: This has not been tested and may contain errors and incorrect assumptions

function Set-FolderACLPermissions([string]$SecurityPrincipal, [string]$PermissionType, [string]$PermissionState, [string]$SearchDir, [string]$SearchTarget) 
{
    $PermissionScope = New-Object System.Security.AccessControl.FileSystemAccessRule($SecurityPrincipal,$PermissionType,'ContainerInherit,ObjectInherit','None',$PermissionState)
    $TargetFolders = Get-ChildItem -Directory -Path '\\?\'+$SearchDir -Recurse -Filter $SearchTarget | select-object FullName
    foreach($TargetFolder in $TargetFolders)
    {
        $Acl = Get-ACL -Path $TargetFolder.FullName.substring(4)
        $Acl.SetAccessRuleProtection($false,$true)
        $Acl.AddAccessRule($PermissionScope)
        Set-Acl $TargetFolder.FullName.substring(4) $ACL
    }   
}
