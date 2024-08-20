#Windows-DisableIPv6

#Failsafe trigger, if file is found, script will not run
$FailsafeExist = Test-Path -Path C:\Windows-DisableIPv6\failsafe.block
if ($FailsafeExist -eq $true)
{
    exit
}

#Makes sure the target is not an exchange server
$ExchangeExist = Get-Service -name MSExchangeServiceHost
if ($ExchangeExist -ne $null)
{
    #Create folder structure to be used
    $FolderExist = Test-Path -Path C:\Windows-DisableIPv6
    if ($FolderExist -ne $true)
    {
        New-Item -ItemType "directory" -Path C:\Windows-DisableIPv6 | Out-Null
        sleep 1
    }
    New-Item -ItemType "file" -Path C:\Windows-DisableIPv6\failsafe.block | Out-Null
    exit
}


#Minor shell setup
$ProgressPreference = "SilentlyContinue"
$hostname = hostname

#Require script to be run as admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false)
{
  Clear-Host
  write-host "Please run as admin..."
  sleep 1
  break
}

#Create folder structure to be used
$FolderExist = Test-Path -Path C:\Windows-DisableIPv6
if ($FolderExist -ne $true)
{
    New-Item -ItemType "directory" -Path C:\Windows-DisableIPv6 | Out-Null
    sleep 1
}
#Gets the current time to be used as timestamp suffix and removes any non-digits from string
$WholeTime = Get-Date -UFormat "%T"
#This regex is overkill but ensures removal of non-digits regardless of formatting used by system
$FormattedTime = $WholeTime -replace "[^\p{N}]+"

$transcriptFile = "C:\Windows-DisableIPv6\RollbackLog_" + "$FormattedTime" + ".txt"
Start-Transcript -Path $transcriptFile

#Check if the patch is already installed for logging purposes
$HotFixes = Get-Hotfix | Select-Object HotFixID
foreach ($HotFix in $HotFixes) 
{
    #Note: Only KBs for Windows Server 2012, 2012R2, 2016, 2019, and 2022 are checked, as no 2008R2 or older servers are expected to be present
    if (($HotFix.HotFixID -match "KB5041578") -or ($HotFix.HotFixID -match "KB5041160") -or ($HotFix.HotFixID -match "KB5041773") -or ($HotFix.HotFixID -match "KB5041828") -or ($HotFix.HotFixID -match "KB5041851")) 
    {
        clear-host
        write-host ""
        write-host "Please note that this server has already been patched with the required security update"
        write-host "The script will continue to disable IPv6 on all interfaces regardless"
        write-host ""
        break
    }
}

$ShareHostname = "QZQZQPLACEHOLDERQZQZQ2"

#Saves list of interfaces in case rollback is needed
$OutputFile = "C:\Windows-DisableIPv6\RollbackFile_" + "$FormattedTime" + ".csv"
$OutputFileReport = "\\$ShareHostname\Windows-DisableIPv6_Reports\IPv6OriginalSetup_" + "$hostname" + ".csv"
$AllInterfacesAndState = Get-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 | Select-Object Name,Enabled
$AllInterfacesAndState | Export-Csv -Path $OutputFile -NoTypeInformation
$AllInterfacesAndState | Export-Csv -Path $OutputFileReport -NoTypeInformation
$EnabledInterfaces = $AllInterfacesAndState | Where-Object Enabled -eq True

#Create log if first run
$HasReported = Test-Path -Path C:\Windows-DisableIPv6\hasReported.log
if ($HasReported -ne $true)
{
    New-Item -ItemType "file" -Path C:\Windows-DisableIPv6\hasReported.log | Out-Null
    sleep 1
}

#Disables IPv6 on all interfaces
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6

#Creates file to keep logging to only original run to keep logs clean
New-Item -ItemType "file" -Path C:\Windows-DisableIPv6\hasReported.log

clear-host
write-host "IPv6 has now been disabled on the following interfaces:"
foreach ($EnabledInterface in $EnabledInterfaces)
{
    write-host $EnabledInterface.Name
}
write-host ""
write-host "A backup of the previous configuration can be found at"$OutputFile
write-host "In case fallback is required, please reference this file."
write-host "Alternatively use rollback code with the ID"$FormattedTime
write-host ""
Stop-Transcript
break
