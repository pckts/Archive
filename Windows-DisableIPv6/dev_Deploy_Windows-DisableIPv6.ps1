$ProgressPreference = "SilentlyContinue"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false)
{
  Clear-Host
  write-host "Please run as admin..."
  sleep 1
  break
}

$IsDC = Get-WmiObject -Class Win32_OperatingSystem | Select-Object ProductType
if ($IsDC.ProductType -ne "2")
{
  Clear-Host
  write-host "This server is not a Domain Controller"
  write-host "Please retry on a server that has the Domain Controller role"
  write-host ""
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
else
{
    clear-host
    write-host "The main script folder exists already"
    write-host "This folder will be deleted and recreated to ensure integrity"
    write-host ""
    sleep 1
    Remove-SmbShare -Name "Windows-DisableIPv6" -Force
    Remove-Item -LiteralPath "C:\Windows-DisableIPv6" -Force -Recurse
    New-Item -ItemType "directory" -Path C:\Windows-DisableIPv6 | Out-Null
    clear-host
}

$ReportFolderExist = Test-Path -Path C:\Windows-DisableIPv6_Reports
if ($FolderExist -ne $true)
{
    New-Item -ItemType "directory" -Path C:\Windows-DisableIPv6_Reports | Out-Null
    sleep 1
}
else
{
    clear-host
    write-host "The Reports folder exists already"
    write-host "This folder will be deleted and recreated to ensure integrity"
    write-host ""
    sleep 1
    Remove-SmbShare -Name "Windows-DisableIPv6_Reports" -Force
    Remove-Item -LiteralPath "C:\Windows-DisableIPv6_Reports" -Force -Recurse
    New-Item -ItemType "directory" -Path C:\Windows-DisableIPv6_Reports | Out-Null
    clear-host
}

#Shares the folder
New-SmbShare -Name "Windows-DisableIPv6" -Path "C:\Windows-DisableIPv6" -ReadAccess "Everyone"
New-SmbShare -Name "Windows-DisableIPv6_Reports" -Path "C:\Windows-DisableIPv6_Reports" -ChangeAccess "Everyone"
$hostname = hostname
$ShareRemotePath = "\\"+$hostname+"\Windows-DisableIPv6"
$ShareLocalPath = "C:\Windows-DisableIPv6"

#Downloads script and source files for GPO
$URLSource = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9naXRodWIuY29tL3Bja3RzL1dpbmRvd3MtRGlzYWJsZUlQdjYvcmF3L21haW4vV2luZG93cy1EaXNhYmxlSVB2NlNvdXJjZS56aXA="))
$URLScript = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL3Bja3RzL1dpbmRvd3MtRGlzYWJsZUlQdjYvbWFpbi9XaW5kb3dzLURpc2FibGVJUHY2LnBzMQ=="))
$URLTask = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL3Bja3RzL1dpbmRvd3MtRGlzYWJsZUlQdjYvbWFpbi9DbGVhbnVwX1dpbmRvd3MtRGlzYWJsZUlQdjYueG1s"))

Invoke-WebRequest -Uri $URLSource -OutFile $ShareLocalPath\Windows-DisableIPv6Source.zip
Invoke-WebRequest -Uri $URLScript -OutFile $ShareLocalPath\Windows-DisableIPv6.ps1
Invoke-WebRequest -Uri $URLTask -OutFile $ShareLocalPath\Cleanup_Windows-DisableIPv6.xml

Try
{
    Expand-Archive -LiteralPath $ShareLocalPath\Windows-DisableIPv6Source.zip -DestinationPath $ShareLocalPath
}
catch
{
    cls
    write-host "Powershell version is outdated and does not contain required functionality."
    write-host "Please download and install Windows Management Framework 5.1"
    write-host "You can not continue until this is installed."
    write-host ""
    $DownloadWMF = read-host "Do you want to go to the download page before closing? (Y/N)"
    if ($DownloadWMF = "y")
    {
        Start-Process "https://www.microsoft.com/en-us/download/details.aspx?id=54616"
        cls
        break
    }
    else
    {
        break
    }
}


#Replaces the placeholder in the XML for the scheduled cleanup task with runtime 2 weeks in the future
$DatePlaceholderToReplace = "QQQQ-QQ-QQ"
$DateThen = (Get-Date).AddDays(14)
$FormattedDateThen = Get-Date $DateThen -Format "yyyy-MM-dd"
$TaskXMLPath = "$ShareLocalPath\Cleanup_Windows-DisableIPv6.xml"
(Get-Content -path $TaskXMLPath -Raw) -replace $DatePlaceholderToReplace,$FormattedDateThen | Set-Content -Path $TaskXMLPath

#Replaces the placeholder in the XML for the scheduled task, with the real hostname
$PlaceholderToReplace = "QZQZQPLACEHOLDERQZQZQ"
$XMLPath = "$ShareLocalPath\WDIP6_Source\{B4BA155A-AB98-4943-9610-328DD1EA1C37}\DomainSysvol\GPO\Machine\Preferences\ScheduledTasks\ScheduledTasks.xml"
(Get-Content -path $XMLPath -Raw) -replace $PlaceholderToReplace,$hostname | Set-Content -Path $XMLPath

#Replaces the placerholder sharepath in the active script
$PlaceholderToReplace2 = "QZQZQPLACEHOLDERQZQZQ2"
$ScriptPath = "$ShareLocalPath\Windows-DisableIPv6.ps1"
(Get-Content -path $ScriptPath -Raw) -replace $PlaceholderToReplace2,$hostname | Set-Content -Path $ScriptPath

#Replaces the generic domain in the MOF for the WMI filter, with the real domain
$GenericDomainToReplace = "domain.local"
$MOFPath = "$ShareLocalPath\WDIP6_Source\IPv6WMIFilter.mof"
$RealDomain = [System.Net.NetworkInformation.IpGlobalProperties]::GetIPGlobalProperties().DomainName
(Get-Content -path $MOFPath -Raw) -replace $GenericDomainToReplace,$RealDomain | Set-Content -Path $MOFPath

#Imports the WMI filter
mofcomp -N:root\Policy "$ShareLocalPath\WDIP6_Source\IPv6WMIFilter.mof"

#Deploys the GPO, enforces it, and links it to any OU with inheritance disabled
$GPOName = "Windows-DisableIPv6"
$DoesGPOExist = Get-GPO -All | Where-Object {$_.displayname -like "Windows-DisableIPv6"}
if ($null -ne $DoesGPOExist)
{
    Remove-GPO -Name $GPOName
}

$Partition = Get-ADDomainController | Select-Object DefaultPartition
$GPOSource = "C:\Windows-DisableIPv6\WDIP6_Source"
import-gpo -BackupId B4BA155A-AB98-4943-9610-328DD1EA1C37 -TargetName $GPOName -path $GPOSource -CreateIfNeeded
Get-GPO -Name $GPOName | New-GPLink -Target $Partition.DefaultPartition
Set-GPLink -Name $GPOName -Enforced Yes -Target $Partition.DefaultPartition
$DisabledInheritances = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
Foreach ($DisabledInheritance in $DisabledInheritances) 
{
    New-GPLink -Name $GPOName -Target $DisabledInheritance.Path
    Set-GPLink -Name $GPOName -Enforced Yes -Target $DisabledInheritance.Path
}

#Links the WMI filter to the GPO
$DomainDn = "DC=" + [String]::Join(",DC=", $RealDomain.Split("."))
$SystemContainer = "CN=System," + $DomainDn
$GPOContainer = "CN=Policies," + $SystemContainer
$WMIFilterContainer = "CN=SOM,CN=WMIPolicy," + $SystemContainer
$GPReportPath = "$ShareLocalPath\WDIP6_Source\{B4BA155A-AB98-4943-9610-328DD1EA1C37}\gpreport.xml"
[xml]$GPReport = get-content $GPReportPath
$WMIFilterDisplayName = $GPReport.GPO.FilterName
$GPOAttributes = Get-GPO $GPOName
$WMIFilter = Get-ADObject -Filter 'msWMI-Name -eq $WMIFilterDisplayName'
$GPODN = "CN={" + $GPOAttributes.Id + "}," + $GPOContainer
$WMIFilterLinkValue = "[$RealDomain;" + $WMIFilter.Name + ";0]"
Set-ADObject $GPODN -Add @{gPCWQLFilter=$WMIFilterLinkValue}

#Creates cleanup task that will automatically remove the GPO in 2 weeks from date of implementation
$taskExists = schtasks /Query /tn "Cleanup_Windows-DisableIPv6"
if ($taskExists -eq $null)
{
    schtasks /Create /XML "$ShareLocalPath\Cleanup_Windows-DisableIPv6.xml" /tn "Cleanup_Windows-DisableIPv6"
}

#Cleans up
Remove-Item -LiteralPath $ShareLocalPath\Windows-DisableIPv6Source.zip -Force
Remove-Item -LiteralPath $ShareLocalPath\WDIP6_Source -Force -Recurse
Remove-Item -LiteralPath $ShareLocalPath\Cleanup_Windows-DisableIPv6.xml -Force

clear-host
write-host "The group policy 'Windows-DisableIPv6' has now been deployed"
write-host ""
write-host "It will automatically be deleted in 2 weeks to allow for re-use of IPv6."
write-host "Goodbye"
write-host ""
sleep 1
break
