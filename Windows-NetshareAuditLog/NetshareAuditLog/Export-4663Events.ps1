# Get the current date and format it as YYYY-MM-DD
$date = Get-Date -Format "yyyy-MM-dd"

# Get events from the last hour
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = 4663
    StartTime = (Get-Date).AddHours(-1)
}

# Define the path to the file for the current date
$filePath = "C:\NetshareAuditLog\LogArchive\$date-Audit.xml"

# Export each event to the XML file
foreach ($event in $events) {
    # Export the event as XML
    $eventXML = [xml]$event.ToXml()
    $eventXML = $eventXML.OuterXml

    # Append the event XML to the file
    Add-Content -Path $filePath -Value $eventXML
}

# Remove files older than 1 year
Get-ChildItem -Path "C:\NetshareAuditLog\LogArchive" -Recurse | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddYears(-1) } | Remove-Item