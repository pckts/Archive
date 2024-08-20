#TEMPLATE - For 1 function scripts

#Contains main menu and basic function code for making a simple 1 function script.
#There is only 1 function which outside outside of the main menu context.

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
    write-host "+---FUNCTION-------------------------+" -BackGroundColor Black -NoNewLine; write-host "---README-------------------------------------+" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|                                    |" -BackGroundColor Black -NoNewLine; write-host "                                              |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|                                    |" -BackGroundColor Black -NoNewLine; write-host "                                              |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|                                    |" -BackGroundColor Black -NoNewLine; write-host "                             (CTRL+C to exit) |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "+------------------------------------+" -BackGroundColor Black -NoNewLine; write-host "----------------------------------------------+" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host ""
    $MainMenuFunction01 = read-host "Type 'run' to start"
    
    #If neither function 1 or function 2 is selected, the user is returned to the main menu. This forces the user to make a valid choice.
    if ($MainMenuFunction01 -ne "run")
    {
        &@MainMenu01
    }

    #If function 1 is selected, the code breaks out of the main menu and will continue from the below point.
}
&@MainMenu01
clear-host
#Function starts here
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