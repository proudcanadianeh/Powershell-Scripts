<#
.SYNOPSIS
Prepare Windows VM for Proxmox (2026 Edition):
- Save hardware inventory (CPU, RAM, Disks, IP) to C:\temp\notes.txt
- Uninstall VMware Tools (Registry & Chocolatey)
- Install QEMU Guest Agent & VirtIO Drivers FROM NETWORK SHARE
- Inject VirtIO SCSI driver into kernel for boot-start
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

# ---------- 1. Helper Functions ----------
function Write-Info { param($m) Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-OK   { param($m) Write-Host "[OK] $m" -ForegroundColor Green }
function Write-Warn { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err  { param($m) Write-Host "[ERR] $m" -ForegroundColor Red }

function Ensure-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        throw "This script must be run as Administrator."
    }
}

function Ensure-64Bit {
    if (-not [Environment]::Is64BitProcess) {
        throw "This script must be run in a 64-bit PowerShell process to interact with 64-bit Registry keys and drivers."
    }
}

function Ensure-Dirs {
    foreach ($path in @($TempDir, $CacheDir)) {
        if (-not (Test-Path $path)) { 
            New-Item -Path $path -ItemType Directory -Force | Out-Null 
        }
    }
}

function Test-ChocoPresent {
    return [bool](Get-Command choco.exe -ErrorAction SilentlyContinue)
}

# ---------- 2. Config ----------
$TempDir     = 'C:\temp'
$NotesFile   = Join-Path $TempDir 'notes.txt'
$CacheDir    = Join-Path $TempDir 'installers'
$QemuShare   = '\\path\to\installers'
$MsiName     = 'virtio-win-gt-x64.msi'
$ExeName     = 'virtio-win-guest-tools.exe'

# ---------- 3. Execution Logic ----------

Ensure-64Bit
Ensure-Admin
Ensure-Dirs

# 3a. Save Hardware & Network Inventory
Write-Info "Generating hardware inventory at $NotesFile..."
try {
    $cpu = Get-CimInstance Win32_Processor
    $sockets = ($cpu | Measure-Object).Count
    $cores = ($cpu | Measure-Object -Property NumberOfCores -Sum).Sum
    $ramMB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB)

    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        "$($_.DeviceID) Size: $([math]::Round($_.Size / 1GB)) GB"
    }
    $diskString = $disks -join ", "

    $netConfig = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -ne $null } | Select-Object -First 1
    $ipAddress = $netConfig.IPv4Address.IPAddress
    $interface = Get-NetIPInterface -InterfaceIndex $netConfig.InterfaceIndex -AddressFamily IPv4
    $ipStatus  = if ($interface.Dhcp -eq 'Enabled') { "DHCP" } else { "Static" }

    $report = @"
Number of CPU Sockets: $sockets
Number of CPU Cores:   $cores
Amount of RAM:         $ramMB MB
Attached Drives:       $diskString
Current IP Address:    $ipAddress
IP Configuration:      $ipStatus
"@
    
    $report | Out-File -FilePath $NotesFile -Force
    Write-OK "Inventory saved."
} catch {
    Write-Warn "Failed to gather hardware info: $_"
}

# 3b. Uninstall VMware Tools (Registry)
Write-Info "Checking Registry for VMware Tools..."
$keys = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
$vmwareTools = Get-ItemProperty $keys -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*VMware Tools*" }

foreach ($tool in $vmwareTools) {
    Write-Info "Uninstalling: $($tool.DisplayName)"
    if ($tool.UninstallString -match 'MsiExec') {
        $guid = [regex]::Match($tool.UninstallString, '\{[0-9A-F\-]+\}').Value
        Start-Process msiexec.exe -ArgumentList "/x $guid /qn /norestart" -Wait
    } elseif ($tool.UninstallString) {
        $uninst = $tool.UninstallString -replace "/I", "/X"
        Start-Process cmd.exe -ArgumentList "/c $uninst /S /silent /qn" -Wait
    }
}

# 3c. Uninstall VMware Tools (Chocolatey)
if (Test-ChocoPresent) {
    Write-Info "Checking Chocolatey for existing VMware packages..."
    $chocoPkgs = choco list --local-only -e vmware-tools, open-vm-tools --limit-output
    if ($chocoPkgs) {
        choco uninstall vmware-tools open-vm-tools -y --remove-dependencies --no-progress
    }
}

# 3d. Install QEMU Components
Write-Info "Installing QEMU from network share: $QemuShare"
if (Test-Path $QemuShare) {
    $localMsi = Join-Path $CacheDir $MsiName
    $localExe = Join-Path $CacheDir $ExeName
    
    Copy-Item (Join-Path $QemuShare $MsiName) $localMsi -Force
    Copy-Item (Join-Path $QemuShare $ExeName) $localExe -Force

    Write-Info "Running MSI (Drivers and Agent)..."
    Start-Process msiexec.exe -ArgumentList "/i `"$localMsi`" /qn /norestart" -Wait
    
    Write-Info "Running Guest Tools EXE..."
    Start-Process $localExe -ArgumentList "/S" -Wait
    Write-OK "Installers completed."
} else {
    Write-Err "Could not reach network share: $QemuShare"
    exit 1
}

# 3e. Inject VirtIO SCSI for Boot
Write-Info "Injecting VirtIO SCSI driver..."
$vioscsiInf = $null
$retryCount = 0
$searchPaths = @(
    "C:\Program Files\Virtio-Win\Vioscsi",
    "C:\Program Files\Virtio-Win",
    "C:\Program Files (x86)\Virtio-Win",
    $CacheDir
)

while ($null -eq $vioscsiInf -and $retryCount -lt 6) {
    $vioscsiInf = Get-ChildItem -Path $searchPaths -Recurse -Filter "vioscsi.inf" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $vioscsiInf) {
        Write-Info "Waiting for files (Attempt $($retryCount + 1)/6)..."
        Start-Sleep -Seconds 5
        $retryCount++
    }
}

if ($null -ne $vioscsiInf) {
    Write-OK "Found driver at: $($vioscsiInf.FullName)"
    try {
        pnputil /add-driver $vioscsiInf.FullName /install
        
        $servicePath = "HKLM:\SYSTEM\CurrentControlSet\Services\vioscsi"
        if (-not (Test-Path $servicePath)) {
            New-Item -Path $servicePath -Force | Out-Null
            New-Item -Path "$servicePath\Parameters" -Force | Out-Null
            New-Item -Path "$servicePath\Parameters\PnpInterface" -Force | Out-Null
        }

        $regValues = @{
            "Start"         = 0
            "Type"          = 1
            "ErrorControl"  = 1
            "ImagePath"     = "System32\drivers\vioscsi.sys"
            "LoadOrderGroup"= "SCSI miniport"
        }

        foreach ($name in $regValues.Keys) {
            $type = if ($name -eq "ImagePath") { "ExpandString" } else { "DWord" }
            if ($name -eq "LoadOrderGroup") { $type = "String" }
            Set-ItemProperty -Path $servicePath -Name $name -Value $regValues[$name] -Type $type
        }
        Write-OK "VirtIO SCSI registered as a Boot-Start service."
    } catch {
        Write-Err "Failed to inject SCSI driver: $_"
    }
} else {
    Write-Err "Could not locate vioscsi.inf. Migration may fail with BSOD."
}

Write-OK "Script Complete. Please run enable-vioscsi-to-load-on-boot.ps1 to finish loading the SCSI driver for first boot."
