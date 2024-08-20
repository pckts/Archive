#TEMPLATE - For 2 function scripts

#Contains main menu and basic function code for making a simple 2 function script.
#Function 1 starts after the main menu, as function 1 should be primary and what should contain main/most code.
#Function 2 is contained within the main menu, as it contains either "undo" or informational code, which is typically less complicated/shorter.

#===============================#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #
# REMOVE ABOVE BEFORE DEPLOYING #
#===============================#


#========#
# ^^^^^^ #
# README #
#========#

########################################################################################################################################################################################################################

#Detects if the script is run in admin context, if it is not, the script will exit after letting the user know.
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false)
{
    clear-host
    write-warning "Script needs to be run as admin."
    break
}

#==========================#
# Modules and dependencies #
# VVVVVVVVVVVVVVVVVVVVVVVV #
#==========================#

# Sets the TLS settings to allow downloads via HTTPS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# QoL setting, prevents the shells progressbar from blocking text
$ProgressPreference = "SilentlyContinue"

# import-module [module]
# install-module [module]

#==========================#
# ^^^^^^^^^^^^^^^^^^^^^^^^ #
# Modules and dependencies #
#==========================#

#Shows the startup banner main menu.
$MainMenu01 = 
{
    start-sleep 1
    clear-host
    write-host "";
    write-host "                                       " -BackGroundColor Black -NoNewLine; write-host "By ANTLA" -ForeGroundColor Red -BackGroundColor Black -NoNewLine; write-host "                                      " -BackGroundColor Black
    write-host "        " -BackGroundColor Black -NoNewLine; write-host "████████╗███████╗███╗   ███╗██████╗ ██╗      █████╗ ████████╗███████╗" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "        " -BackGroundColor Black
    write-host "        " -BackGroundColor Black -NoNewLine; write-host "╚══██╔══╝██╔════╝████╗ ████║██╔══██╗██║     ██╔══██╗╚══██╔══╝██╔════╝" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "        " -BackGroundColor Black
    write-host "        " -BackGroundColor Black -NoNewLine; write-host "   ██║   █████╗  ██╔████╔██║██████╔╝██║     ███████║   ██║   █████╗  " -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "        " -BackGroundColor Black
    write-host "        " -BackGroundColor Black -NoNewLine; write-host "   ██║   ██╔══╝  ██║╚██╔╝██║██╔═══╝ ██║     ██╔══██║   ██║   ██╔══╝  " -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "        " -BackGroundColor Black
    write-host "        " -BackGroundColor Black -NoNewLine; write-host "   ██║   ███████╗██║ ╚═╝ ██║██║     ███████╗██║  ██║   ██║   ███████╗" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "        " -BackGroundColor Black
    write-host "        " -BackGroundColor Black -NoNewLine; write-host "   ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "        " -BackGroundColor Black
    write-host "                                                                                     " -BackGroundColor Black
    write-host "+---FUNCTIONS------------------------+" -BackGroundColor Black -NoNewLine; write-host "---README-------------------------------------+" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|1. (function)                       |" -BackGroundColor Black -NoNewLine; write-host "                                              |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|                                    |" -BackGroundColor Black -NoNewLine; write-host "                                              |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|------------------------------------|" -BackGroundColor Black -NoNewLine; write-host "                                              |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|2. (function)                       |" -BackGroundColor Black -NoNewLine; write-host "                                              |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|                                    |" -BackGroundColor Black -NoNewLine; write-host "                             (CTRL+C to exit) |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "+------------------------------------+" -BackGroundColor Black -NoNewLine; write-host "----------------------------------------------+" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host ""
    $MainMenuFunction01 = read-host "Select function (1/2)"
    
    #If neither function 1 or function 2 is selected, the user is returned to the main menu. This forces the user to make a valid choice.
    if ($MainMenuFunction01 -ne "1" -and $MainMenuFunction01 -ne "2")
    {
        &@MainMenu01
    }

    #Function 2 will typically be a shorter "undo" or even purely informational part of the script, and most often results in returning to the main menu, so it makes sense to keep this within the main menu block.
    #If function 2 is selected, this will run:
    if ($MainMenuFunction01 -eq "2")
    {
        #FUNCTIONALITY
    }

    #If function 1 is selected, the code breaks out of the main menu and will continue from the below point.
}
&@MainMenu01
clear-host
#Function 1 starts here
#===================================#
# Please add functional code  below #
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV #
#===================================#


#if ($Placeholder -eq $null)
#{
#    get-code
#}
    

#===================================#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #
# Please add functional code  above #
#===================================#