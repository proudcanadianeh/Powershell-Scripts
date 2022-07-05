write-host "Welcome to Brians crappy Chia powershell script for deteching your pool address V1"

#Running checks
try {$version = Get-ChildItem $env:APPDATA\..\Local\chia-blockchain\ -Name app-* }catch{ echo "Version not detected";exit;}
try {test-path $env:USERPROFILE\.chia\mainnet\config\ssl\wallet\private_wallet.crt}catch{ echo "Wallet not detected. Please configure";exit;}
#end checks

$output = cmd /c $env:APPDATA\..\Local\chia-blockchain\$version\resources\app.asar.unpacked\daemon\chia.exe plotnft show 2`>`&1
echo $output
