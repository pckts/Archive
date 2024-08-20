$DeployConfig = Get-Content .\DCDeployConfig.xml
$DeployConfig | % { $_.Replace("REPLACEHOSTNAME", "$env:computername") } | Set-Content .\DCDeployConfig.xml
Install-WindowsFeature –ConfigurationFilePath .\DCDeployConfig.xml
cls
$DOMAINFULL = Read-Host -Prompt 'What is the FQDN?'
cls
$DOMAINSHORT = $DOMAINFULL.split('.')[0]
Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "$DOMAINFULL" `
-DomainNetbiosName "$DOMAINSHORT" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true