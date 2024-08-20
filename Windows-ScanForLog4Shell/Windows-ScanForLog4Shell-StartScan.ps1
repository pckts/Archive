$WorkingPath = "[\\SHARE\PATH]" 
#fx "\\DC01\Log4Shell"

cd $WorkingPath
& '.\log4j_scanner.exe'
exit