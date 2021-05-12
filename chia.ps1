write-host "Welcome to Brians crappy Chia powershell script V3"

#Running checks
try {$version = Get-ChildItem $env:APPDATA\..\Local\chia-blockchain\ -Name app-* }catch{ echo "Version not detected";exit;}
try {test-path $env:USERPROFILE\.chia\mainnet\config\ssl\wallet\private_wallet.crt}catch{ echo "Wallet not detected. Please configure";exit;}
#end checks

Write-Host "Detected drives:"
    Get-WmiObject -Class Win32_logicaldisk | Select-Object -Property DeviceID, VolumeName, @{L='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}},@{L="Capacity";E={"{0:N2}" -f ($_.Size/1GB)}} | out-host

Write-Host "Enter TMP drive:"
$tmpdrv = Read-Host
write-host "Enter Final Drive:"
$finaldrv = Read-Host
write-host "How many plots do you wish to make? (1)"
$number = Read-Host
if (!$number){$number = "1"}
$arguments = "plots create -k 32 -b 3389 -u 128 -r 2 -t $tmpdrv`:\Chia\tmp -d $finaldrv`:\Chia\Final -n $number"
write-host $arguments
start-process -filepath $env:APPDATA\..\Local\chia-blockchain\$version\resources\app.asar.unpacked\daemon\chia.exe -ArgumentList $arguments