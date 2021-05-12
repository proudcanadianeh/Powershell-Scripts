write-host "Welcome to Brians crappy Chia powershell script V2"

#Running checks
try {$version = Get-ChildItem $env:APPDATA\..\Local\chia-blockchain\ -Name app-* }catch{ echo "Version not detected";exit;}

#end checks

Write-Host "Detected drives:"
    Get-WmiObject -Class Win32_logicaldisk | Select-Object -Property DeviceID, VolumeName, @{L='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}},@{L="Capacity";E={"{0:N2}" -f ($_.Size/1GB)}} | out-host

Write-Host "Enter TMP drive:"
$tmpdrv = Read-Host
write-host "Enter Final Drive:"
$finaldrv = Read-Host
$arguments = "plots create -k 32 -b 3389 -u 128 -r 2 -t $tmpdrv`:\Chia\tmp -d $finaldrv`:\Chia\Final -n 1"
write-host $arguments
start-process -filepath $env:APPDATA\..\Local\chia-blockchain\$version\resources\app.asar.unpacked\daemon\chia.exe -ArgumentList $arguments