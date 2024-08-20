<# (H)ybrid (A)zure (R)eadiness (C)heck (HARK)

 ######################
 # INTERNAL USE ONLY! #
 ######################

 #######
 # FAQ #
 #######

 Q: What is the HARK toolkit?
 A: The HARK toolkit is a set of powershell scripts designed to check and verify the readiness 
    of an existing on-prem enviornment, for it's move to and integration with Azure services.

 Q: Can the HARK toolkit be used to assses the readiness for a cloud-only transition?
 A: The HARK toolkit is used to asses the on-prem enviornments compatibility with equivalent Azure services.
    This makes the HARK toolkit suitable for cloud-only assesment as well. 
    Most cloud-only moves contain a hybrid stepping stone and as such have the same requirements.

 Q: Does the HARK toolkit handle the cloud transition and migration for me?
 A: No. The HARK toolkit is simply a set of tools to asses and analyse the current enviornment, to give the
    architect a fundamental understanding of the current landscape, to effectively guide the client in their transition.

 Q: If the HARK toolkit is only for analysis, how will I implement the requested changes?
 A: Please refer to the (A)utomated (R)emediation and (P)reperation (ARP) toolkit
    The ARP toolkit is designed to be used with HARK.

 #######

 #######################
 # Functionality index #
 #######################

 Devices and Intune
 Q: Where do I run this tool?
 A: Execute it as admin on any DC of the forest.


    Task 1: List GPOs and their settings (Better to import or restructure to configuration profiles?)
    Task 2: List logon scripts
    Task 3: Is LAPS installed
    Task 4: List device OS (Minimum Windows 10 2004 required)


 #######################
#> 