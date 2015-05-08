$getdisk = get-disk | ?{$_.DiskNumber -ne 0} |Out-GridView -PassThru
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
Clear-Disk -Number $getdisk.DiskNumber -RemoveData -RemoveOEM -PassThru | 
Initialize-Disk -PartitionStyle MBR -PassThru |
New-Partition -UseMaximumSize -AssignDriveLetter | 
Format-Volume

#>