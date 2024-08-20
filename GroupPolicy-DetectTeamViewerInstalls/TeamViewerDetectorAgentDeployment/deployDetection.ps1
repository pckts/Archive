# This script was created with a sense of urgency and consists primarily of reused code from other projects
# For this reason the code may not be optimised, however it is fully functional

#------------------------------------------------------------------------------------#

# Ensures script folder is placed correctly
$ScriptFolderCorrect = Test-Path -Path "$home\desktop\TeamViewerDetectorAgentDeployment\deployDetection.ps1"
if ($ScriptFolderCorrect -ne $true)
{
    Clear-host
    Write-host "The 'TeamViewerDetectorAgentDeployment' folder must be placed on the Desktop..."
    sleep 1
    break
}
#------------------------------------------------------------------------------------#

# Ensures script is run as admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false)
{
    Clear-host
    Write-host "Please run as admin..."
    sleep 1
    break
}
#------------------------------------------------------------------------------------#

# Creates the TeamViewerDetector root folder and TMVVULAgentSource working directory if they do not already exist
# Afterwards the TMVVULAgentSource working directory folder is shared, and 'Everyone' is given Change (read+write) permission in the ACL
$DoesTeamViewerDetectorRootExist = Test-Path -Path C:\TeamViewerDetector
if ($DoesTeamViewerDetectorRootExist -ne $true)
{
    New-Item -ItemType "directory" -Path C:\TeamViewerDetector
    New-Item -ItemType "directory" -Path C:\TeamViewerDetector\TMVVULAgentSource
}
else
{
    $DoesTMVVULFolderExist = Test-Path -Path C:\TeamViewerDetector\TMVVULAgentSource
    if ($DoesTMVVULFolderExist -ne $true)
    {
        New-Item -ItemType "directory" -Path C:\TeamViewerDetector\TMVVULAgentSource
    }
}
New-SmbShare -Name TMVVULAgentSource -Path C:\TeamViewerDetector\TMVVULAgentSource | Grant-SmbShareAccess -AccountName Everyone -AccessRight Change -Force
#------------------------------------------------------------------------------------#

# Creates the 'Agent script' - this runs on endpoint devices checking if TeamViewer is installed by testing the known default install path
$TMVVUL_agentScript = {Set-ExecutionPolicy Unrestricted -force
$Resultdump = "\\SERVERHOSTNAMEPLACEHOLDER\TMVVULAgentSource\agentVerdicts.txt"
$EndpointHostname = $env:COMPUTERNAME
$isTeamViewerInstalled = Test-path -path "C:\Program Files\TeamViewer\TeamViewer.exe"
$agentVerdict = $EndpointHostname+" - Teamviewer: "+$isTeamViewerInstalled+"`n"
$agentVerdict | out-file $ResultDump -Encoding unicode -Append
Set-ExecutionPolicy Restricted -force}
$TMVVUL_agentScript | Out-File -FilePath "C:\TeamViewerDetector\TMVVULAgentSource\TMVVUL_agentScript.ps1"
#------------------------------------------------------------------------------------#

# Replaces the placeholder text in previously generated 'Agent script' with the real shared folder UNC path
# This method is used as a workaround due to time constraints, and serves as to resolve the issue of the generated 'Agent script' containing the variable name instead of the variable value
# Additionally it fixes the path to the agent script in the final Group Policy
$ServerHostname = $env:COMPUTERNAME
(Get-Content "C:\TeamViewerDetector\TMVVULAgentSource\TMVVUL_agentScript.ps1") -replace “SERVERHOSTNAMEPLACEHOLDER”, $ServerHostname | Set-Content -Path "C:\TeamViewerDetector\TMVVULAgentSource\TMVVUL_agentScript.ps1"
(Get-Content "$home\desktop\TeamViewerDetectorAgentDeployment\{2A69460E-FC4D-4F42-B2A3-7EE30D7AD5C9}\DomainSysvol\GPO\Machine\Scripts\PSscripts.ini") -replace “PATHPLACEHOLDER”, "\\$ServerHostname" | Set-Content -Path "$home\desktop\TeamViewerDetectorAgentDeployment\{2A69460E-FC4D-4F42-B2A3-7EE30D7AD5C9}\DomainSysvol\GPO\Machine\Scripts\PSscripts.ini"

#------------------------------------------------------------------------------------#

# Checks if Group Policy already exists, if it does, it will delete the policy including all existing policy links etc
# This is done to allow a simple re-run of this entire script as a method of troubleshooting and/or rebuilding the deployment
$DoesGPOExist = Get-GPO -All | Where-Object {$_.displayname -like "TeamViewerDetectorAgentDeployment"}
if ($null -ne $DoesGPOExist)
{
    Remove-GPO -Name "TeamViewerDetectorAgentDeployment"
}
#------------------------------------------------------------------------------------#

# Imports the Group Policy and links it to the root of the domain (top of OU tree)
$Partition = Get-ADDomainController | Select-Object DefaultPartition
$GPOSource = "$home\desktop\TeamViewerDetectorAgentDeployment"
import-gpo -BackupId 2A69460E-FC4D-4F42-B2A3-7EE30D7AD5C9 -TargetName "TeamViewerDetectorAgentDeployment" -path $GPOSource -CreateIfNeeded
Get-GPO -Name "TeamViewerDetectorAgentDeployment" | New-GPLink -Target $Partition.DefaultPartition
Set-GPLink -Name "TeamViewerDetectorAgentDeployment" -Enforced Yes -Target $Partition.DefaultPartition
#------------------------------------------------------------------------------------#

# Finds all Organisational Units (OUs) where inheritance is disabled, and explicitly links the Grouo Policy to these OUs
$DisabledInheritances = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
Foreach ($DisabledInheritance in $DisabledInheritances) 
{
    New-GPLink -Name "TeamViewerDetectorAgentDeployment" -Target $DisabledInheritance.Path
    Set-GPLink -Name "TeamViewerDetectorAgentDeployment" -Enforced Yes -Target $DisabledInheritance.Path
}
#------------------------------------------------------------------------------------#

# Deletes the script folder including all content - this is to avoid leaving behind internal tools on customer environments
Remove-Item -Path $GPOSource -Recurse -Force
#------------------------------------------------------------------------------------#

# The end