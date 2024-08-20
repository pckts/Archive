$banner = {
clear-host
write-host "";
write-host "  " -BackGroundColor Black -NoNewLine; write-host "██████╗ ████████╗███████╗████████╗██████╗  █████╗  ██████╗███████╗" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
write-host "  " -BackGroundColor Black -NoNewLine; write-host "██╔══██╗╚══██╔══╝██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
write-host "  " -BackGroundColor Black -NoNewLine; write-host "██████╔╝   ██║   █████╗     ██║   ██████╔╝███████║██║     █████╗  " -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
write-host "  " -BackGroundColor Black -NoNewLine; write-host "██╔══██╗   ██║   ██╔══╝     ██║   ██╔══██╗██╔══██║██║     ██╔══╝  " -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
write-host "  " -BackGroundColor Black -NoNewLine; write-host "██║  ██║   ██║   ███████╗   ██║   ██║  ██║██║  ██║╚██████╗███████╗" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
write-host "  " -BackGroundColor Black -NoNewLine; write-host "╚═╝  ╚═╝   ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
write-host "                                                                      " -BackGroundColor Black
write-host "+---FUNCTIONS---------+" -BackGroundColor Black -NoNewLine; write-host "---README-------------------------------------+" -ForeGroundColor DarkGray -BackGroundColor Black
write-host "|1. (trace)           |" -BackGroundColor Black -NoNewLine; write-host " This script is used for tracing route/tracert|" -ForeGroundColor DarkGray -BackGroundColor Black
write-host "|Trace specific hosts |" -BackGroundColor Black -NoNewLine; write-host " multiple hosts for an extended period of time|" -ForeGroundColor DarkGray -BackGroundColor Black
write-host "|---------------------|" -BackGroundColor Black -NoNewLine; write-host "                                              |" -ForeGroundColor DarkGray -BackGroundColor Black
write-host "|2. (flush)           |" -BackGroundColor Black -NoNewLine; write-host "                                              |" -ForeGroundColor DarkGray -BackGroundColor Black
write-host "|Flush/Reset DNS cache|" -BackGroundColor Black -NoNewLine; write-host "                        For Internal use only |" -ForeGroundColor DarkGray -BackGroundColor Black
write-host "+---------------------+" -BackGroundColor Black -NoNewLine; write-host "----------------------------------------------+" -ForeGroundColor DarkGray -BackGroundColor Black
write-host  
$selectedFunction = Read-Host "Choose function (1/2)"

    if ($selectedFunction -eq 1 -or $selectedFunction -eq "trace")
    {
        clear-host
        $hostnameAll = {$hostname}.Invoke()
        while ($addedHost -ne "DONE")
        {
            if ($hostnameAll -ne $null)
            {
                write-host "Selected hosts:"
                $hostnameAll
                write-host;
            }
            write-host "Please input host(s) you want to trace, one at a time." 
            write-host "Press Enter after each host. Input 'done' when finished."
            write-host;
            $addedHost = Read-Host "Hostname"
            $hostnameAll.Add($addedHost)
            clear-host
        }
        $hostnameAll.RemoveAt(0)
        $hostnameAll.Remove("done")
        clear-host
        write-host "Please select where to save the logfile."
        Add-Type -AssemblyName System.Windows.Forms
        $logFilePath=New-Object System.Windows.Forms.SaveFileDialog

        if($logFilePath.ShowDialog() -eq 'Ok')
        {
            $logFileFull = $($logFilePath.filename)
        }
        else
        {
            Clear-Variable -Name "hostnameAll"
            &$banner
        }

        clear-host
        write-host "The program will now continously cycle through all the hosts."
        write-host "please press CTRL+C to stop it."
        $badcoding = "true"
        while ($badcoding = "true")
        {
            ForEach ($hostnameSingle in $hostnameAll)
            {
                write-host;
                write-host "Currently tracing" $hostnameSingle
                tracert -w 10 -h 2 $hostnameSingle | Add-Content $logFileFull
                write-host "Completed, continuing to next host"
                sleep -milliseconds (500)
                write-host;
                write-host "====================================="
            }
        }
    }

    if ($selectedFunction -eq 2 -or $selectedFunction -eq "flush")
    {
        clear-host
        ipconfig /flushdns
        clear-host; write-host "DNS cache has now been flushed/reset."; sleep -milliseconds (500);
        &@banner
    }

    if ($selectedFunction -ne 1 -and $selectedFunction -ne 2 -and $selectedFunction -ne "trace" -and $selectedFunction -ne "flush")
    {
        write-host "ERROR: Invalid option" -ForeGroundColor Red -BackGroundColor Black
        sleep -milliseconds (500)
        &@banner
    }
}
&@banner
