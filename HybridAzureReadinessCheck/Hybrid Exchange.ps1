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

 Hybrid Exchange
 Q: Where do I run this tool?
 A: Execute it as admin on the exchange server
 WARNING: DAG setups not currently supported

    Task 1: List User mailboxes 0-48GB (Will require Exchange Online E1)
    Task 2: List User mailboxes 48-98GB (Will require Exchange Online E2)
    Task 3: List User mailboxes over 98GB (NOT SUPPORTED)
    Task 4: List Shared mailboxes 0-48GB (Does generally not require license)
    Task 5: List Shared mailboxes 48-98GB (Will require Exchange Online E2)
    Task 6: List Shared mailboxes over 98GB (NOT SUPPORTED)
    Task 7: List Room mailboxes
    Task 8: List Public folders (They must be converted to shared mailboxes)
    Task 9: List accepted domains
    Task 10: List Transport rules
    Task 11: List SMTP connections (To find printers and scripts etc that utilise exch server)
    Task 12: List calendar permissions
    Task 13: List send-as permissions
    Task 14: List full-access permissions
    Task 15: List forwards
    Task 16: List auto-respond/OOF
    Task 17: List mailbox rules
    Task 18: Convert AD groups used for mailbox membership to mail-enabled and universal


 #######################
#> 