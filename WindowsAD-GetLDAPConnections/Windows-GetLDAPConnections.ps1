Get-NetTCPConnection | Where {$_.LocalPort -EQ "389"} | Select LocalAddress, LocalPort, RemoteAddress, RemotePort, State |
Export-csv $home\desktop\ldap.csv -NoTypeInformation -Encoding Unicode
$exclude = @("::1", "::", "127.0.0.1", "0.0.0.0")
$obj_list = @()
$csv = import-csv $home\desktop\itrldap.csv -ErrorAction SilentlyContinue
foreach($c in $csv)
{
    if($null -ne ($exclude | ? { $C.RemoteAddress -match $_ })){continue}
    $hostname = (Resolve-DnsName $c.RemoteAddress -ErrorAction Continue).NameHost
    $obj = New-Object PSObject -Property @{
        Hostname = $hostname
        RemoteAddress = $c.RemoteAddress
        }
    $obj_list += ($obj)
}
remove-item $home\desktop\ldap.csv
$obj_list | Sort-Object -Property @{Expression={$_.RemoteAddress}} -Unique | Out-GridView