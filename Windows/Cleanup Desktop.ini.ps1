<#
Simply drop this script into the partent folder and it will remove desktop.ini from all first level subfolders
#>


$folders = gci -Path $PSScriptRoot | where {$_.PSIsContainer}

foreach ($foldername in $folders){
if (Test-Path -Path "$PSScriptRoot\$foldername\desktop.ini"){
rm "$PSScriptRoot\$foldername\desktop.ini" -Force -ErrorAction SilentlyContinue
echo "Deleted desktop.ini from user $foldername"
}
}