$ForwardTarget = "@domain.tld"
#edit @domain.tld to desired target domain

connect-exchangeonline
$mailboxes = Get-Mailbox | Where-Object {$_.ForwardingSmtpAddress -Match $ForwardTarget} | Select-Object UserPrincipalName,ForwardingSmtpAddress
foreach ($mailbox in $mailboxes)
{
	set-mailbox $mailbox.UserPrincipalName -ForwardingSmtpAddress $null
}
$mailboxes = Get-Mailbox | Where-Object {$_.ForwardingAddress -Match $ForwardTarget} | Select-Object UserPrincipalName,ForwardingAddress
foreach ($mailbox in $mailboxes)
{
	set-mailbox $mailbox.UserPrincipalName -ForwardingAddress $null
}
