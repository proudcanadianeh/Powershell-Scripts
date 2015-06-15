$getdisk = get-disk | ?{$_.DiskNumber -ne 0} |Out-GridView -PassThru
if (!$getdisk){ exit }
$detected = $null
foreach ($disk in (Get-Partition -DiskNumber $getdisk.DiskNumber)){
$drive = $disk.DriveLetter + ":\users"
$users = Get-ChildItem -Path $drive -Directory -ErrorAction SilentlyContinue | ?{$_.name -notlike 'admin*' -and $_.Name -notlike 'bagland' -and $_.Name -notlike 'tris*' -and $_.Name -ne 'Public'}
$detected = $detected + $users.name
} 
echo "The folloing users were detected:"
echo $detected
$conf = Read-Host "Do you want to proceed?(y/n)"
if ($conf -ne 'y')
{
exit
}
cls
$newpart = Clear-Disk -Number $getdisk.DiskNumber -RemoveData -RemoveOEM -PassThru | 
Initialize-Disk -PartitionStyle MBR -PassThru |
New-Partition -UseMaximumSize -AssignDriveLetter | 
Format-Volume -FileSystem NTFS
$conf = Read-Host "Quick format of " $newpart.DriveLetter "complete. To benchmark speed press 1, for full format press 2, or anything else to exit."
if ($conf -eq 1){
echo "Benchmark"
}elseif ($conf -eq 2){
echo "Beginning format. Expect this to take a while"
Format-Volume -DriveLetter $newpart.DriveLetter -FileSystem NTFS -Full -Force 

}else{
exit
}
#>