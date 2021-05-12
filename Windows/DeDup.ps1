Clear-Host
if (!$vol){
echo "Enter the drive letter:"
$vol = Read-Host
}
clear-host
$running = Get-DedupJob
echo "****************************Data-De-Duplication Manager **********************"
echo " "
if ($running.state -eq "Running") { 
write-host -nonewline $running.type"Job is currently running"
Write-Host "`n"
}
echo "Choose from one of the following:"
echo "1. Check progress of running job"
echo "2. Start new job on drive $vol"
echo "3. Stop running job"
echo "4. Live display of progress"
echo "5. Exit"

write-host "Selection?"
$select = Read-Host

if ($select -eq "1"){
Clear-Host
Get-DedupJob
}elseif ($select -eq "2"){
clear-host
write-host "Note! Manually started jobs run at highest priority!
What type of job would you like?
1. Optimization 
2. Garbage Cleanup 
3. Garbage Cleanup (Full)
4. Scrubbing (Verify Data)
Selection?
"
$select = Read-Host
if ($select -eq 1){ Start-DedupJob -type optimization -Volume $vol -Priority High}
elseif ($select -eq 2){ Start-DedupJob -type GarbageCollection -Volume $vol -Priority High}
elseif ($select -eq 3){ Start-DedupJob -type GarbageCollection -full -Volume $vol -Priority High}
elseif ($select -eq 4){ Start-DedupJob -type scrubbing -Volume $vol -Priority High}
 


}elseif ($select -eq "3"){
write-host "Stopping..."
Stop-DedupJob $vol 
}elseif ($select -eq "4"){
for ($j = 0 ; $j -le 10000; $j++) 
{ 
  Get-DedupJob | %{
Write-Progress -Id $_.ProcessId -Activity ($_.Volume + " - " + $_.Type) -Status ($_.State.ToString() +  " " + $_.Progress.ToString() + "% percent complete") -PercentComplete $_.Progress}; 
 
    Start-Sleep 2 | out-null;
}
}else{ echo "Done." }

