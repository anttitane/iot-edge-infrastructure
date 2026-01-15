param(
    [Parameter(Mandatory = $true)][string]$HubName,
    [string]$DeviceListPath = "devices.txt",
    [switch]$PrintConnectionStrings,
    [switch]$PruneNotInList
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $DeviceListPath -PathType Leaf)) {
    Write-Error "Device list file not found: $DeviceListPath"
}

$deviceIds = Get-Content -Path $DeviceListPath | ForEach-Object { $_.Trim() } | Where-Object { $_ -and (-not $_.StartsWith('#')) }
if (-not $deviceIds) {
    Write-Error "No device IDs found in $DeviceListPath"
}

Write-Host "Ensuring Azure IoT extension is installed..." -ForegroundColor Cyan
try {
    az extension add --name azure-iot --yes > $null
    if ($LASTEXITCODE -ne 0) { throw "az extension add failed with exit code $LASTEXITCODE" }
} catch {
    Write-Error "Failed to install azure-iot extension. Run 'az extension add --name azure-iot --yes --debug' manually to troubleshoot."; return
}

Write-Host "Fetching existing Edge devices..." -ForegroundColor Cyan
$existing = @()
try {
    $existing = az iot hub device-identity list --hub-name $HubName --query "[?capabilities.iotEdge==`true`].deviceId" -o tsv
    if ($LASTEXITCODE -ne 0) { throw "az iot hub device-identity list failed with exit code $LASTEXITCODE" }
    $existing = $existing | ForEach-Object { $_.Trim() } | Where-Object { $_ }
} catch {
    Write-Error "Failed to list existing Edge devices. Ensure hub '$HubName' exists and you are logged in (az login)."; return
}

$existingArray = @()
if ($existing) { $existingArray = [string[]]$existing } else { $existingArray = @() }
$desiredArray = @()
if ($deviceIds) { $desiredArray = [string[]]$deviceIds } else { $desiredArray = @() }

$existingSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$existingArray)
$desiredSet  = [System.Collections.Generic.HashSet[string]]::new([string[]]$desiredArray)

foreach ($id in $deviceIds) {
    Write-Host "Creating/updating Edge device '$id' in hub '$HubName'..." -ForegroundColor Cyan
    az iot hub device-identity create --device-id $id --hub-name $HubName --edge-enabled --output none

    if ($PrintConnectionStrings) {
        $conn = az iot hub device-identity connection-string show --device-id $id --hub-name $HubName --query "connectionString" -o tsv
        Write-Output "${id}: $conn"
    }
}

if ($PruneNotInList) {
    $toRemove = $existingSet.Where({ -not $desiredSet.Contains($_) })
    foreach ($id in $toRemove) {
        Write-Host "Deleting Edge device '$id' (not in list)..." -ForegroundColor Yellow
        az iot hub device-identity delete --device-id $id --hub-name $HubName --yes --output none
    }
}

Write-Host "Done." -ForegroundColor Green
