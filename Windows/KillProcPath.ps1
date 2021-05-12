$visual = $null
write-host "Enter the parent folder of processes you wish to kill:"
$killpath = Read-Host
$visual = Get-Process | select-object ID,Path,Name 
foreach ($kill in $Visual){
if ($kill.Path -like $killpath){
echo $kill.Name
Stop-Process $kill.Id -Force
}
}


