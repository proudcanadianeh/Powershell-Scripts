$psversion = $PSVersionTable.PSVersion.Major

if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
    Write-Host "Module exists, exiting"
    exit
}

if ($psversion -ge 5){

Install-PackageProvider -Name NuGet -Force

Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers

Get-WUServiceManager

}else{
echo "Error, PS is out of date"
}