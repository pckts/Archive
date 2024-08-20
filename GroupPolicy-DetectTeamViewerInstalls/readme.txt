

#=============# Scenario  ONE #=============#
# Devices are managed with Active Directory #
#==============# ON-PREMISES #==============#

1. Unzip TeamViewerDetectorAgentDeployment.zip
NOTE: The "TeamViewerDetectorAgentDeployment" folder may become double nested during unzip operation

2. RDP into a suitable DOMAIN CONTROLLER (DC) server in the customer environment
NOTE: The server MUST be a DOMAIN CONTROLLER (DC)

3. Copy and paste the ENTIRE "TeamViewerDetectorAgentDeployment" folder to the DESKTOP of the server
NOTE: The "TeamViewerDetectorAgentDeployment" folder MUST be placed on the DESKTOP

4. Open the "TeamViewerDetectorAgentDeployment" folder and double-click the InstallTMVVULAgents.bat file
NOTE: This will likely cause a User Access Control (UAC) prompt to appear asking if you want to elevate to and run as Administrator - click YES to this!

5. The script will now automatically generate various folders and scripts, and subsequently self-deletes.
NOTE: This is a hands-off process and takes only a few seconds - if interested in the operation please refer to the deployDetection.ps1 file.

OPTIONAL: Verify a successful deployment by locating the "TeamViewerDetectorAgentDeployment" Group Policy in the Group Policy Manager

6. Wait a few days and check the agentVerdicts.txt file located in C:\TeamViewerDetector\TMVVULAgentSource on the server
NOTE: This file lists endpoints that have reported with their TeamViewer installation status
False = No TeamViewer detected
True  = TeamViewer detected

#=============# Scenario  TWO #=============#
# Devices are managed with Microsoft Intune #
#=================# CLOUD #=================#

1. Go to https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMonitorMenu/~/discoveredApps in Private/Incognito browser
NOTE: Private/Incognito browser is optional but helps prevent conflicts when handling multiple tenants

2. Log in with admin credentials for customer tenant
NOTE: Some customers will only allow access via the Microsoft Partner Portal instead

3. Search for TeamViewer
NOTE: This is done in the "Search by application name" input field

4. If results are found, click the discovered TeamViewer app to see list of devices
NOTE: Multiple TeamViewer apps might appear as they are seperated by version
