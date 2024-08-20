clear-host
$ID = Read-Host "Please enter ID"
$BackupFile = "C:\Windows-DisableIPv6\RollbackFile_" + "$ID" + ".csv"
$BackupFileValid = test-path $BackupFile
$ValidIDs = get-childitem -Path "C:\Windows-DisableIPv6" -File | Select-Object Name
if ($BackupFileValid -eq $false)
{
    clear-host
    write-host "The entered ID does not match any saved configurations"
    write-host "Please try again"
    write-host ""
    write-host "List of valid IDs:"
    foreach ($ValidID in $ValidIDs)
    {
        $ValidIDTrimmed = $ValidID.Name -replace "[^\p{N}]+"
        write-host $ValidIDTrimmed.Substring(1)
    }
    write-host ""
    break
}
[array]$BackupInterfaces = Import-Csv -Path $BackupFile
$InterfacesToEnable = $BackupInterfaces | Where-Object Enabled -eq True
foreach ($InterfaceToEnable in $InterfacesToEnable)
{
    Enable-NetAdapterBinding -Name $InterfaceToEnable.Name -ComponentID ms_tcpip6
}
New-Item -ItemType "file" -Path C:\Windows-DisableIPv6\failsafe.block | Out-Null
clear-host
write-host "IPv6 has now been re-enabled on the following interfaces:"
foreach ($ReenabledInterface in $InterfacesToEnable)
{
    write-host $ReenabledInterface.Name
}
write-host ""
break
