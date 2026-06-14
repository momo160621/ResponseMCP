[CmdletBinding()]
param(
    [string]$TenantId,
    [string]$SubscriptionId,
    [switch]$ForceLogin,
    [switch]$SkipBrowserOpen,
    [switch]$UseDeviceCode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-CommandAvailable {
    param([Parameter(Mandatory = $true)][string]$Name)

    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Open-Url {
    param([Parameter(Mandatory = $true)][string]$Url)

    if ($SkipBrowserOpen) {
        Write-Host "URL: $Url"
        return
    }

    try {
        Start-Process $Url | Out-Null
        return
    }
    catch {
    }

    if (Test-CommandAvailable -Name 'xdg-open') {
        & xdg-open $Url | Out-Null
        return
    }

    if (Test-CommandAvailable -Name 'open') {
        & open $Url | Out-Null
        return
    }

    Write-Host "Open this URL manually: $Url"
}

function Ensure-AzLogin {
    $context = Get-AzContext -ErrorAction SilentlyContinue

    if (-not $context -or $ForceLogin) {
        Write-Host 'Connecting to Azure...'

        if ($UseDeviceCode) {
            if ($TenantId) {
                Connect-AzAccount -Tenant $TenantId -UseDeviceAuthentication | Out-Null
            }
            else {
                Connect-AzAccount -UseDeviceAuthentication | Out-Null
            }
        }
        else {
            if ($TenantId) {
                Connect-AzAccount -Tenant $TenantId | Out-Null
            }
            else {
                Connect-AzAccount | Out-Null
            }
        }
    }

    if ($SubscriptionId) {
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    }
}

if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
    throw 'The Az.Accounts module is required. Run: pwsh ./audit-reader/scripts/install-reader-prereqs.ps1 -IncludeResourceGraph'
}

Import-Module Az.Accounts -ErrorAction Stop
Ensure-AzLogin

$currentContext = Get-AzContext
Write-Host ''
Write-Host 'Current Azure context'
Write-Host '---------------------'
Write-Host "Tenant       : $($currentContext.Tenant.Id)"
Write-Host "Subscription : $($currentContext.Subscription.Name)"
Write-Host "Account      : $($currentContext.Account.Id)"
Write-Host ''
Write-Host 'Opening the main portals used for Sentinel and Defender XDR audit...'
Write-Host ''

$urls = @(
    'https://security.microsoft.com',
    'https://portal.azure.com',
    'https://entra.microsoft.com'
)

foreach ($url in $urls) {
    Open-Url -Url $url
}

Write-Host ''
Write-Host 'Recommended navigation paths'
Write-Host '----------------------------'
Write-Host 'Defender portal:'
Write-Host '- Microsoft Sentinel'
Write-Host '- Incidents'
Write-Host '- Hunting'
Write-Host '- Configuration > Watchlists'
Write-Host '- Configuration > Analytics'
Write-Host '- Configuration > Data connectors'
Write-Host ''
Write-Host 'Azure portal:'
Write-Host '- Log Analytics workspaces'
Write-Host '- Microsoft Sentinel workspaces'
Write-Host '- Resource groups'
Write-Host '- Azure Policy'
Write-Host ''
Write-Host 'Entra admin center:'
Write-Host '- Roles and administrators'
Write-Host '- Sign-in logs'
Write-Host '- Risky users'
Write-Host ''
Write-Host 'Use this script only for sign-in, context confirmation, and portal opening.'
Write-Host 'No tenant configuration is changed by this script.'
