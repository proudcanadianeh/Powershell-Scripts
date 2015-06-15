$then = (Get-Date).AddDays(-60) # The 60 is the number of days from today since the last logon.

Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $then -and OperatingSystem -eq "Windows 7 Professional" } | Sort-Object Name | FT Name,lastLogonDate
