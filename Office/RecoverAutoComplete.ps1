# %userprofile%\appdata\local\Microsoft\Outlook\RoamCache

$largest = Get-ChildItem -Path $env:LOCALAPPDATA\Microsoft\Outlook\RoamCache -Filter "Stream_Autocomplete*" | Sort-Object -Property Length -Descending | select -First 1
echo "$largest is largest"
$newest = Get-ChildItem -Path $env:LOCALAPPDATA\Microsoft\Outlook\RoamCache -Filter "Stream_Autocomplete*" | Sort-Object -Property CreationTime -Descending |select -First 1
echo "$newest is newest"
Stop-Process -processname Outlook -Force -ErrorAction SilentlyContinue

Rename-Item $env:LOCALAPPDATA\Microsoft\Outlook\RoamCache\$newest "backup_$newest"
Rename-Item $env:LOCALAPPDATA\Microsoft\Outlook\RoamCache\$largest "$newest"