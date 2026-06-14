[CmdletBinding()]
param(
    [switch]$IncludeResourceGraph,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$requiredModules = @(
    'Az.Accounts',
    'Az.Resources',
    'Az.OperationalInsights'
)

if ($IncludeResourceGraph) {
    $requiredModules += 'Az.ResourceGraph'
}

try {
    $gallery = Get-PSRepository -Name 'PSGallery' -ErrorAction Stop
    if ($gallery.InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    }
}
catch {
    Write-Warning 'Unable to configure PSGallery as Trusted automatically. You may be prompted during module installation.'
}

foreach ($moduleName in $requiredModules) {
    $installed = Get-Module -ListAvailable -Name $moduleName
    if ($installed -and -not $Force) {
        Write-Host "Already installed: $moduleName"
        continue
    }

    Write-Host "Installing: $moduleName"
    Install-Module -Name $moduleName -Scope CurrentUser -Force:$Force -AllowClobber
}

Write-Host ''
Write-Host 'Reader prerequisites installed.'
Write-Host 'Next steps:'
Write-Host '1. pwsh ./audit-reader/scripts/connect-portals-reader.ps1 -UseDeviceCode'
Write-Host '2. pwsh ./audit-reader/scripts/export-sentinel-xdr-reader-inventory.ps1 -UseDeviceCode'