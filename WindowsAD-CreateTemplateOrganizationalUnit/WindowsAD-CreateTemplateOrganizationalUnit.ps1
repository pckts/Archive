


echo "+---------------------------+"
echo "|       Company Name        |"
echo "+---------------------------+"
echo ""
echo 'What is the company name?'
echo "(No spaces)"
echo ""
$CompanyName = read-host 'Company Name'
cls

echo "+---------------------------+"
echo "|          Language         |"
echo "+---------------------------+"
echo ""
echo "Which language should the OUs be in?"
echo ""
$LangSelect = Read-Host "(E)nglish/(D)anish"
if ($LangSelect -eq 'e' -or $LangSelect -eq 'english')
{
    cls
    New-ADOrganizationalUnit -Name "$CompanyName" -Path "DC=domain,DC=local" -ProtectedFromAccidentalDeletion $False
    New-ADOrganizationalUnit -Name "Users" -Path "OU=$CompanyName,DC=domain,DC=local" -ProtectedFromAccidentalDeletion $False
    New-ADOrganizationalUnit -Name "Admin" -Path "OU=Users,OU=$CompanyName,DC=domain,DC=local" -ProtectedFromAccidentalDeletion $False
    New-ADOrganizationalUnit -Name "User" -Path "OU=Users,OU=$CompanyName,DC=domain,DC=local" -ProtectedFromAccidentalDeletion $False
    cls
}
if ($LangSelect -eq 'd' -or $LangSelect -eq 'danish')
{
    cls
    New-ADOrganizationalUnit -Name "$CompanyName" -Path "DC=domain,DC=local" -ProtectedFromAccidentalDeletion $False
    New-ADOrganizationalUnit -Name "Brugere" -Path "OU=$CompanyName,DC=domain,DC=local" -ProtectedFromAccidentalDeletion $False
    New-ADOrganizationalUnit -Name "Admin" -Path "OU=Brugere,OU=$CompanyName,DC=domain,DC=local" -ProtectedFromAccidentalDeletion $False
    New-ADOrganizationalUnit -Name "Bruger" -Path "OU=Brugere,OU=$CompanyName,DC=domain,DC=local" -ProtectedFromAccidentalDeletion $False
    cls
}
if ($LangSelect -ne 'e' -and $LangSelect -ne 'd' -and $LangSelect -ne 'english' -and $LangSelect -ne 'danish')
{
    cls
    echo "Please choose a language"
    pause
}
