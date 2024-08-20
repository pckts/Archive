<# (H)ybrid (A)zure (R)eadiness (C)heck (HARK)

 ######################
 # INTERNAL USE ONLY! #
 ######################

 #######
 # FAQ #
 #######

 Q: What is the HARK toolkit?
 A: The HARK toolkit is a set of powershell scripts designed to check and verify the readiness 
    of an existing on-prem enviornment, for it's move to and integration with Azure services.

 Q: Can the HARK toolkit be used to assses the readiness for a cloud-only transition?
 A: The HARK toolkit is used to asses the on-prem enviornments compatibility with equivalent Azure services.
    This makes the HARK toolkit suitable for cloud-only assesment as well. 
    Most cloud-only moves contain a hybrid stepping stone and as such have the same requirements.

 Q: Does the HARK toolkit handle the cloud transition and migration for me?
 A: No. The HARK toolkit is simply a set of tools to asses and analyse the current enviornment, to give the
    architect a fundamental understanding of the current landscape, to effectively guide the client in their transition.

 Q: If the HARK toolkit is only for analysis, how will I implement the requested changes?
 A: Please refer to the (A)utomated (R)emediation and (P)reperation (ARP) toolkit
    The ARP toolkit is designed to be used with HARK.

 #######

 #######################
 # Functionality index #
 #######################

 Azure AD Connect and Hybrid AD
 Q: Where do I run this tool?
 A: Execute it as admin on the primary DC of the forest.

 Disclaimer: It is not considered best practice to run the AD Connect service on the DC itself.
 However: This advice is intended for enterprises with multi-hundred-thousand objects and tens of DCs. 
 For most SMBs it will be okay to run the AD Connect service on a DC.

 What does the tool do:
 - Ensure primary DC and the schema is at least 2012R2
   Why: Anything older than 2012R2 is EOL.
   Where: 139-171

 - Ensure DC is writeable
   Why: RODC (Read Only DC) is not supported for AD Connect.
   Where: 174-201
   
 - Ensure no dotted NetBIOS names
   Why: Dotted NetBIOS names are not supported. Can possibly be renamed if no Exchange server exists on the domain but with much effort.
   Example: INT.PARCEU instead of INT (when full domain is int.parceu.com) or PARCEU.COM instead of PARCEU (when full domain is parceu.com)
   Where: 204-233
   
 - Ensure AD Recycle bin is enabled
   Why: Not a hard requirement but is best practice and has no negative consequences. Ensures ability to restore accounts in the event of an incident.
   Where: 236-263
   
 - Ensure minimum .Net Framework 4.6.2 installed
   Why: Required for the AD Connect software.
   Where: 266-294
   
 - Ensure server is either not essentials
   Why: Essentials version of Windows Server is not supported.
   Where: 297-325
   
 - Ensure server is not a core version
   Why: a desktop enviornment is required to run and manage AD Connect
   Where: 328-354
   
 - Ensure Powershell 5.0 or newer is installed
   Why: Required for AD Connect software
   Where: 357-386
   
 - Ensure minimum 2 CPU cores and 4gb ram
   Why: Not a hard requirement but strongly advised. Recommended minimum specifications for most SMB setups.
   Where: 389-444
   
 - Ensure TLS 1.2 is enabled
   Why: New versions of AD Connect will utilise TLS 1.2 for connectivity, which provides a more secure setup.
   Where: 447-474
   
 - Ensure domain and default UPN is a routable domain
   Why: If the domain is not the routable version of the clients domain. ie. parcue.local rather than parceu.com, AD connect will be unable
   to match accounts on UPN and users will be unable to login using the same credentials in on-prem and cloud.
   If the default UPN and domain itself is non-routable, the easy fix is to add a routable UPN and change the AD objects to this new routable UPN.
   Further explained: Additionally sub domains are fully supported but require additional setup and administration, so it is generally considered good practice to 
   reduce administrative overhead, to also ensure the domain is not ie. int.parceu.com but simply parceu.com. (This will otherwise be a headache for the Exchange admin)
   Because of this stance, HARK will consider subdomain forests incompatible to the same extend as a non-routable one.
   Where: 477-520
   
 - Ensure password policy is responsibily configured
   Why: In many legacy setups the password policy will align with outdated and insecure standards.
   Based on the recommendations of various industry leaders, the following password policy is recommended by HARK
   x Minimum 12 characters
   x LockoutThreshold set to 5
   x PasswordHistory set to at least 10
   x Complexity enabled
   Where: 523-604
   
 - Warn of existing or previous AADConnect installs
   Why: If the AD Connect software is already installed, it must be uninstalled and cleaned up before proceeding.
   You must follow proper cleanup and remediation procedures if setting up a new sync agent for a tenant and/or domain, that has previously existed in a hybrid setup.
   Where: 607-593
   
 #######################
 Confused by lack of segmentation beyond this point? where did the variable come from? what does it reference?
 Tip: Powershell will ALWAYS run from top to bottom, look above what you're confused by!

 The code starts now...
#>

#This is a baseline setting to create a cleaner execution process
$ProgressPreference = "SilentlyContinue"
###

#Ensure script is run as admin - if it is not run as admin, it will break (exit)
#It is a hard requirement to run the script as admin, do not attempt to circumvent this.
#Do you not have the neccesary local rights to execute as admin? Contact the server owner.

#Creates a variable that contains the value for current security principal
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

#Checks if the value contained within the $currentPrincipal aligns with the Administrator role, if it doesn't not ($false) it will execute the code
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false)
{
  #Clears the console for previous code for a clean look
  Clear-Host
  #Writes the following text to the console, informing the architect what to do
  write-host "Please run as admin..."
  #Waits 1 second
  sleep 1
  #Breaks, which is like exiting but without closing the window, giving the architect time to read previous output
  break
}
###

#Ensure AD Schema is at least 2012R2
#Creates a variable that contains the value of property objectVersion extracted from schemaNamingContext
#This number value will correspond to a schema version.
$ADSChemaVer = Get-ADObject (Get-ADRootDSE).schemaNamingContext -Properties objectVersion
#Trims down the variable value to be only the number
$ADSChemaVer = $ADSChemaVer.objectVersion

#Checks if the objectVersion value contained within $ADSchemaVer is less than 69. If it is, it will execute the code
#objectVersion 69 corresponds to 2012R2, previous versions have a lower value.
if ($ADSChemaVer -lt 69)
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to AD schema being 2012 or older
  $VerdictADSChemaVer = "Fail"
  $VerdictADSChemaVerColour = "Red"
}

#Checks if the objectVersion value contained within $ADSchemaVer is equal to or greather than 69. If it is, it will execute the code
#objectVersion 69 corresponds to 20012R2. Newer versions have a greater value.
elseif ($ADSChemaVer -ge 69)
{
  #Sets a variable containing the value 2 which in the final sum up report will correlate to AD schema being 2012R2 or newer.
  $VerdictADSChemaVer = "Pass"
  $VerdictADSChemaVerColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictADSChemaVer = "Unknown"
  $VerdictADSChemaVerColour = "Yellow"
}
###

#Ensure DC is writeable
#Creates variable containing value of isreadonly
$RODC = (Get-ADDomainController -Identity $env:COMPUTERNAME).isreadonly

#Checks if the isreadonly value contained within $RODC is $true, if it is, it will execute the code
if ($RODC -eq $true)
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the DC being read only
  $VerdictRODC = "Fail"
  $VerdictRODCColour = "Red"
}

#Checks if the isreadonly value contained within $RODC is $false, if it is, it will execute the code
elseif ($RODC -eq $false)
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the DC being writable
  $VerdictRODC = "Pass"
  $VerdictRODCColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictRODC = "Unknown"
  $VerdictRODCColour = "Yellow"
}
###

#Ensure no dotted NetBIOS names
#Creates variable containing the value of NetBIOSName
$NetBIOSName = (Get-ADDomain -Server $env:COMPUTERNAME).NetBIOSName

#Checks if the NetBIOSName value contained within $NetBIOSName contains any dots/periods, if it does, it will execute the code
#Regex is used for this check as period is a special character.
if ($NetBIOSName -match '[\.]')
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the NetBIOS name having any dot(s)
  $VerdictNetBIOS = "Fail"
  $VerdictNetBIOSColour = "Red"
}

#Checks if the NetBIOSName value contained within $NetBIOSName contains any dots/periods, if it doesn't, it will execute the code
#Regex is used for this check as period is a special character.
elseif ($NetBIOSName -notmatch '[\.]')
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the NetBIOS name not having any dot(s)
  $VerdictNetBIOS = "Pass"
  $VerdictNetBIOSColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictNetBIOS = "Unknown"
  $VerdictNetBIOSColour = "Yellow"
}
###

#Ensure AD Recycle bin is enabled
#Creates variable containing the value of EnabledScopes of the Recycle Bin Feature result
$ADRecycleBin = (Get-ADOptionalFeature -Filter 'name -like "Recycle Bin Feature"').EnabledScopes

#Checks if the EnabledScopes value contained within $ADRecycleBin is empty, if it is, it will execute the code
if (-not $ADRecycleBin)
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the AD Recycle Bin being disabled
  $VerdictADRecycleBin = "Fail"
  $VerdictADRecycleBinColour = "Red"
}

#Checks if the EnabledScopes value contained within $ADRecycleBin is not empty, if it isn't, it will execute the code
elseif ($ADRecycleBin)
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the AD Recycle Bin being enabled
  $VerdictADRecycleBin = "Pass"
  $VerdictADRecycleBinColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictADRecycleBin = "Unknown"
  $VerdictADRecycleBinColour = "Yellow"
}
###

#Ensure minimum .Net Framework 4.6.2 installed
#Creates variable containing the registry value pertaining to the .NET Framework version
$DotNETVer = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release
#.NET Framework version 4.6.2 has the value 394802

#Checks if the .NET Framework value contained within $DotNetVer is less than 394802, if it is, it will execute the code
if ($DotNETVer -lt 394802)
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to .NET Framework being older than 4.6.2
  $VerdictDotNETVer = "Fail"
  $VerdictDotNETVerColour = "Red"
}

#Checks if the .NET Framework value contained within $DotNetVer is equal to or greater than 394802, if it is, it will execute the code
elseif ($DotNETVer -ge 394802)
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to .NET Framework being 4.6.2 or newer
  $VerdictDotNETVer = "Pass"
  $VerdictDotNETVerColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictDotNETVer = "Unknown"
  $VerdictDotNETVerColour = "Yellow"
}
###

#Ensure server is not essentials
#Creates variable containing the value of OsOperationSystemSKU from ComputerInfo
$OSVersion = Get-ComputerInfo | Select-Object OsOperatingSystemSKU

#Checks if the OsOperationSystemSKU value contained within $OSVersion doesn't contain either Standard, Datacenter, or Enterprise. if it doesn't, it will execute the code
#In theory more versions exist, but those would be just as incompatible as Essentials and are exceptionally rare in modern setups. Only the above 3 versions are supported.
if ($OSVersion -notmatch 'Standard' -and $OSVersion -notmatch 'Datacenter' -and $OSVersion -notmatch 'Enterprise')
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the OS being an essentials version
  $VerdictOSEssentials = "Fail"
  $VerdictOSEssentialsColour = "Red"
}

#Checks if the OsOperationSystemSKU value contained within $OSVersion contains either Standard, Datacenter, or Enterprise. if it does, it will execute the code
elseif ($OSVersion -match 'Standard' -or $OSVersion -match 'Datacenter' -or $OSVersion -match 'Enterprise')
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the OS not being an essentials version
  $VerdictOSEssentials = "Pass"
  $VerdictOSEssentialsColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictOSEssentials = "Unknown"
  $VerdictOSEssentialsColour = "Yellow"
}
###

#Ensure server is not a core version
#Reuses $OSVersion variable from previous segment

#Checks if the OsOperationSystemSKU value contained within $OSVersion contains core. if it does, it will execute the code
if ($OSVersion -match 'Core')
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the OS being a core version
  $VerdictOSCore = "Fail"
  $VerdictOSCoreColour = "Red"
}

#Checks if the OsOperationSystemSKU value contained within $OSVersion doesn't contain core. if it doesn't, it will execute the code
elseif ($OSVersion -notmatch 'Core')
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the OS not being a core version
  $VerdictOSCore = "Pass"
  $VerdictOSCoreColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictOSCore = "Unknown"
  $VerdictOSCoreColour = "Yellow"
}
###

#Ensure Powershell 5.0 or newer is installed
#Creates variable containing the value of PSVersion from PSVersionTable
$PSVer = $PSVersionTable.PSVersion
#Trims down the variable value to be only the major version value, which is what we're interested in
$PSVer = $PSVer.Major

#Checks if the major PS version is less than 5. if it is, it will execute the code
if ($PSVer -lt 5)
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the PS version being older than 5.0
  $VerdictPSVer = "Fail"
  $VerdictPSVerColour = "Red"
}

#Checks if the major PS version is 5 or greater. if it is, it will execute the code
elseif ($PSVer -ge 5)
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the PS version 5.0 or newer
  $VerdictPSVer = "Pass"
  $VerdictPSVerColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictPSVer = "Unknown"
  $VerdictPSVerColour = "Yellow"
}
###

#Ensure minimum 2 CPU cores and 4gb ram
#Creates variable containing the value of LogicalProcessors
$CPUAmount = (Get-ComputerInfo -Property "CsNumberOfLogicalProcessors").CsNumberOfLogicalProcessors

#Checks if the RAM amount less than 4GB. if it is, it will execute the code
if ($CPUAmount  -lt 2)
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the CPU core count being less than 2
  $VerdictCPUAmount = "Fail"
  $VerdictCPUAmountColour = "Red"
}

#Checks if the RAM amount 4GB or more. if it is, it will execute the code
elseif ($CPUAmount  -ge 2)
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the CPU core count being 2 or more
  $VerdictCPUAmount = "Pass"
  $VerdictCPUAmountColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictCPUAmount = "Unknown"
  $VerdictCPUAmountColour = "Yellow"
}

#Creates variable containing the value of PhysicalMemory
$RAMAmount = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum

#Checks if the RAM amount less than 4GB. if it is, it will execute the code
if ($RAMAmount  -lt 4000000000)
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the RAM amount being less than 4GB
  $VerdictRAMAmount = "Fail"
  $VerdictRAMAmountColour = "Red"
}

#Checks if the RAM amount 4GB or more. if it is, it will execute the code
elseif ($RAMAmount  -ge 4000000000)
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the RAM amount being 4GB or more
  $VerdictRAMAmount = "Pass"
  $VerdictRAMAmountColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictRAMAmount = "Unknown"
  $VerdictRAMAmountColour = "Yellow"
}
###

#Ensure TLS 1.2 is enabled
#Creates variable containing the value of available security protocols
$TLSVer = [Net.ServicePointManager]::SecurityProtocol

#Checks if the RAM amount less than 4GB. if it is, it will execute the code
if ($TLSVer -notmatch 'Tls12')
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to TLS 1.2 not being available
  $VerdictTLSVer = "Fail"
  $VerdictTLSVerColour = "Red"
}

#Checks if the RAM amount 4GB or more. if it is, it will execute the code
elseif ($TLSVer -match 'Tls12')
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to TLS 1.2 being available
  $VerdictTLSVer = "Pass"
  $VerdictTLSVerColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictTLSVer = "Unknown"
  $VerdictTLSVerColour = "Yellow"
}
###

#Ensure domain and default UPN is a routable domain
#Creates variable containing the value of the domain from the current AD DC
$DomainRouteable = Get-ADDomainController -Identity $env:COMPUTERNAME | Select-Object domain
#Trims down the variable value to be only the unformatted value
$DomainRouteable = $DomainRouteable.domain
#Counts the amount of dots/periods in the domain name, this is a low-tech way of seeing if it contains subdomains.
#Puts the count into variable
$DomainSubRouteable = ($DomainRouteable.ToCharArray() | Where-Object {$_ -eq '.'} | Measure-Object).Count
#Puts the TLD of the domain into a variable
$DomainTLDRouteable = $DomainRouteable.Split(".")[-1]
#Checks TLD against 5 most common routeable TLDs, failure to align does not neccesarily mean it is not routeable, but that it might be an uncommon TLD
if ($DomainTLDRouteable -eq 'com' -or $DomainTLDRouteable -eq 'dk' -or $DomainTLDRouteable -eq 'net' -or $DomainTLDRouteable -eq 'org' -or $DomainTLDRouteable -eq 'co.uk')
{
  #Sets a variable containing the value true which which correlates to the TLD being routeable
  $VerdictDomainTLDRouteable = $true
}
#If the TLD does not align with recognised routeable TLDs, this code will execute.
else
{
  #Sets a variable containing the value false which which correlates to the TLD being un-routeable
  $VerdictDomainTLDRouteable = $false
}

#Checks if domain ends in recognised TLD. if it doesn't, it will execute the code
if ($DomainSubRouteable -ge 2 -or $VerdictDomainTLDRouteable -eq $false)
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the domain not being routable
  $VerdictDomainRouteable = "Fail"
  $VerdictDomainRouteableColour = "Red"
}

#Checks if domain ends in recognised TLD. if it does, it will execute the code
elseif ($DomainSubRouteable -eq 1 -and $VerdictDomainTLDRouteable -eq $true)
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the domain being routable
  $VerdictDomainRouteable = "Pass"
  $VerdictDomainRouteableColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictDomainRouteable = "Unknown"
  $VerdictDomainRouteableColour = "Yellow"
}
###

#Ensure password policy is responsibily configured
#Creates variable containing the values of various properties related to the default password policy
$PassPolicy = Get-ADDefaultDomainPasswordPolicy | Select-Object ComplexityEnabled, LockoutThreshold, MinPasswordLength, PasswordHistoryCount

#Checks if the minimum password length is less than 12, if it is, it will execute the code
If ($PassPolicy.MinPasswordLength -lt 12) 
{
  #Sets a variable containing the value 0 which will correlate to the minimum password length being less than 12
  $PassPolicyMPL = 0
}
#if the minimum password length is not less than 12, this code will execute
else
{
  #Sets a variable containing the value 1 which will correlate to the minimum password length being 12 or more
  $PassPolicyMPL = 1
}

#Checks if the lockout threshold is less than 5, if it is, it will execute the code
If ($PassPolicy.LockoutThreshold -lt 5)
{
  #Sets a variable containing the value 0 which will correlate to the lockout threshold being less than 5
  $PassPolicyLT = 0
}
#if the lockout threshold is not less than 5, this code will execute
else
{
  #Sets a variable containing the value 1 which will correlate to the lockout threshold being 5 or more
  $PassPolicyLT = 1
}

#Checks if password complexity is required, if it isn't, it will execute the code
if ($PassPolicy.ComplexityEnabled -eq $false) 
{
  #Sets a variable containing the value 0 which will correlate to password complexity not being required
  $PassPolicyCE = 0
}
#if password complexity is not required, this code will execute
else
{
  #Sets a variable containing the value 1 which will correlate to password complexity being required
  $PassPolicyCE = 1
}

#Checks if password history is less than 10, if it is, it will execute the code
If ($PassPolicy.PasswordHistoryCount -lt 10) 
{
  #Sets a variable containing the value 0 which will correlate to password history being less than 10
  $PassPolicyPHC = 0
}
#if password history is not less than 10, this code will execute
else
{
  #Sets a variable containing the value 1 which will correlate to password history being 10 or more
  $PassPolicyPHC = 1
}

#Checks if all requirements for a responsible password policy is fulfilled, if it is, it will execute the code
if ($PassPolicyMPL -eq 1 -and $PassPolicyLT -eq 1 -and $PassPolicyCE -eq 1 -and $PassPolicyPHC -eq 1)
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the password policy being responsibly set up
  $VerdictPassPolicy = "Pass"
  $VerdictPassPolicyColour = "Green"
}
#If not all requirements are met, this code will execute
elseif ($PassPolicyMPL -eq 0 -or $PassPolicyLT -eq 0 -or $PassPolicyCE -eq 0 -or $PassPolicyPHC -eq 0)
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the password policy not being responsibly set up
  $VerdictPassPolicy = "Fail"
  $VerdictPassPolicyColour = "Red"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictPassPolicy = "Unknown"
  $VerdictPassPolicyColour = "Yellow"
}
###

#Warn of existing or previous AADConnect installs
#Creates variables containing the MSOL and SYNC users, which are created by AADConnect
$MSOLUser = Get-ADUser -filter * -Properties * | Where-Object {$_.SamAccountName -like "MSOL_*"}
$SYNCUser = Get-ADUser -filter * -Properties * | Where-Object {$_.SamAccountName -like "SYNC_*"}

#Checks if either the MSOL or SYNC user is not found. if it isn't, it will execute the code
if (-not ($MSOLUser -or $SYNCUser))
{
  #Sets a variable containing the value "Fail" which in the final sum up report will correlate to the MSOL or SYNC user not existing
  $VerdictExistingConnect = "Fail"
  $VerdictExistingConnectColour = "Red"
}

#Checks if either the MSOL or SYNC user is found. if it is, it will execute the code
elseif ($MSOLUser -or $SYNCUser)
{
  #Sets a variable containing the value "Pass" which in the final sum up report will correlate to the MSOL or SYNC user existing
  $VerdictExistingConnect = "Pass"
  $VerdictExistingConnectColour = "Green"
}

#Error handling:
#If all else fails, this code will execute
else 
{
  #Sets a variable containing the value "Unknown" which in the final sum up report will correlate to it having failed.
  $VerdictExistingConnect = "Unknown"
  $VerdictExistingConnectColour = "Yellow"
}
###

clear-Host

write-host "AD Schema Version.: " -NoNewLine; Write-host -ForegroundColor $VerdictADSChemaVerColour $VerdictADSChemaVer
write-host "DC Writeable......: " -NoNewLine; Write-host -ForegroundColor $VerdictRODCColour $VerdictRODC
write-host "No dotted NetBIOS.: " -NoNewLine; Write-host -ForegroundColor $VerdictNetBIOSColour $VerdictNetBIOS
write-host "AD Recycble Bin...: " -NoNewLine; Write-host -ForegroundColor $VerdictADRecycleBinColour $VerdictADRecycleBin
write-host ".NET Version......: " -NoNewLine; Write-host -ForegroundColor $VerdictDotNETVerColour $VerdictDotNETVer
write-host "Not essentials....: " -NoNewLine; Write-host -ForegroundColor $VerdictOSEssentialsColour $VerdictOSEssentials
write-host "Not core..........: " -NoNewLine; Write-host -ForegroundColor $VerdictOSCoreColour $VerdictOSCore
write-host "Powershell version: " -NoNewLine; Write-host -ForegroundColor $VerdictPSVerColour $VerdictPSVer
write-host "Hardware: CPU.....: " -NoNewLine; Write-host -ForegroundColor $VerdictCPUAmountColour $VerdictCPUAmount
write-host "Hardware: RAM.....: " -NoNewLine; Write-host -ForegroundColor $VerdictRAMAmountColour $VerdictRAMAmount
write-host "TLS 1.2...........: " -NoNewLine; Write-host -ForegroundColor $VerdictTLSVerColour $VerdictTLSVer
write-host "Routable domain...: " -NoNewLine; Write-host -ForegroundColor $VerdictDomainRouteableColour $VerdictDomainRouteable
write-host "Password policy...: " -NoNewLine; Write-host -ForegroundColor $VerdictPassPolicyColour $VerdictPassPolicy
write-host "Existing installs.: " -NoNewLine; Write-host -ForegroundColor $VerdictExistingConnectColour $VerdictExistingConnect