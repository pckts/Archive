1. Create R4W11$ share on DC 

2. Edit line 1 of R4W11_ONPREM.ps1 to reflect accurate path to share.

3. Edit RunR4W11.bat script to reflect accurate path to R4W11_ONPREM.ps1

4. Put R4W11_ONPREM.ps1 and RunR4W11.bat files in Netlogon (requires administrator account)

5. Create a GPO that runs script as startup script (not logon, as it needs to run as SYSTEM for required privileges)

6. Add onto GPO that script runs as a scheduled task as SYSTEM. (More frequently = better)

7. Wait 2 weeks

8. use data from CSV report to fill out W11 Readiness report
