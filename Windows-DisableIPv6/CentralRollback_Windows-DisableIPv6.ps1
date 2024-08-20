$WholeTime = Get-Date -UFormat "%T"
$FormattedTime = $WholeTime -replace "[^\p{N}]+"
$transcriptFile = "C:\Windows-DisableIPv6\ActivatedRollback_" + "$FormattedTime" + ".txt"
Start-Transcript -Path $transcriptFile
clear-host
$BackupFiles = "C:\Windows-DisableIPv6\RollbackFile_*.csv"
$OriginalBackupFile = dir $BackupFiles | sort lastwritetime | select -First 1
[array]$BackupInterfaces = Import-Csv -Path $OriginalBackupFile 
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
Stop-Transcript
break
