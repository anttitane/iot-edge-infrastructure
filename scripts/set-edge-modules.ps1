param(
    [Parameter(Mandatory = $true)][string]$HubName,
    [Parameter(Mandatory = $true)][string]$DeviceId,
    [Parameter(Mandatory = $true)][string]$ContentPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $ContentPath -PathType Leaf)) {
    Write-Error "Deployment content file not found: $ContentPath"
}

Write-Host "Ensuring Azure IoT extension is installed..." -ForegroundColor Cyan
try {
    az extension add --name azure-iot --yes > $null
    if ($LASTEXITCODE -ne 0) { throw "az extension add failed with exit code $LASTEXITCODE" }
} catch {
    Write-Error "Failed to install azure-iot extension. Run 'az extension add --name azure-iot --yes --debug' manually to troubleshoot."; return
}

Write-Host "Setting modules for Edge device '$DeviceId' in hub '$HubName'..." -ForegroundColor Cyan
az iot edge set-modules --hub-name $HubName --device-id $DeviceId --content $ContentPath
if ($LASTEXITCODE -ne 0) {
    Write-Error "az iot edge set-modules failed with exit code $LASTEXITCODE"; return
}

Write-Host "Done." -ForegroundColor Green
