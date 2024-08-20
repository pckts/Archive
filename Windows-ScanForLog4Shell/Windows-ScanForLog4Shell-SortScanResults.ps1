cd $PSScriptRoot
$DeviceCollectionNames = $null
$DeviceCollections = Get-Item .\*.zip | Select-Object Name, @{Name="Size";Expression={"{0:F2}" -f ($_.length/1KB)}}
foreach ($DeviceCollection in $DeviceCollections)
{
    if ($DeviceCollection.Size -gt "1,0")
    {
        $DeviceCollectionName = $DeviceCollection.name
        $DeviceCollectionName = $DeviceCollectionName.substring(11)
        $DeviceCollectionName = $DeviceCollectionName.Substring(0, $DeviceCollectionName.IndexOf('_'))
        if (-not ($DeviceCollectionNames -match $DeviceCollectionName))
        {
            $DeviceCollectionNames += $DeviceCollectionName+"`r`n"
        }
    }
    $DeviceCollectionName2 = $DeviceCollection.name
    $DeviceCollectionName2 = $DeviceCollectionName2.substring(11)
    $DeviceCollectionName2 = $DeviceCollectionName2.Substring(0, $DeviceCollectionName2.IndexOf('_'))
    if (-not ($DeviceCollectionNames2 -match $DeviceCollectionName2))
    {
        $DeviceCollectionNames2 += $DeviceCollectionName2+"`r`n"
    }
}
cls
write-host "These devices may be vulnerable:"
write-host ""
write-host $DeviceCollectionNames
write-host ""
write-host "----------------------"
write-host "All scanned hosts:"
write-host ""
write-host $DeviceCollectionNames2
pause