Import-Module ExchangeOnlineManagement
$UserCredential = Get-Credential
Connect-ExchangeOnline -Credential $UserCredential