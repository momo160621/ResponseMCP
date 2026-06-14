[CmdletBinding()]
param(
    [string]$TenantId,
    [string]$SubscriptionId,
    [string]$OutputDir = '',
    [switch]$UseDeviceCode,
    [switch]$SkipResourceGraph
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path (Join-Path $PSScriptRoot '..') 'output'
}

function Ensure-Module {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Module -ListAvailable -Name $Name)) {
        throw "The module $Name is required. Install it with: Install-Module $Name -Scope CurrentUser"
    }

    Import-Module $Name -ErrorAction Stop
}

function Ensure-AzLogin {
    $context = Get-AzContext -ErrorAction SilentlyContinue

    if (-not $context) {
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

function New-OutputDirectory {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

Ensure-Module -Name 'Az.Accounts'
Ensure-Module -Name 'Az.Resources'
Ensure-Module -Name 'Az.OperationalInsights'
Ensure-AzLogin
New-OutputDirectory -Path $OutputDir

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$subscriptionsFile = Join-Path $OutputDir "subscriptions-$timestamp.json"
$workspacesFile = Join-Path $OutputDir "workspaces-$timestamp.json"
$sentinelResourcesFile = Join-Path $OutputDir "sentinel-resources-$timestamp.json"
$summaryFile = Join-Path $OutputDir "inventory-summary-$timestamp.md"

$subscriptions = if ($SubscriptionId) {
    @(Get-AzSubscription -SubscriptionId $SubscriptionId)
}
else {
    @(Get-AzSubscription)
}

if (-not $subscriptions -or $subscriptions.Count -eq 0) {
    throw 'No Azure subscriptions were found for the current account.'
}

$workspaceInventory = New-Object System.Collections.Generic.List[object]
$sentinelResourceInventory = New-Object System.Collections.Generic.List[object]
$resourceGraphAvailable = $false

if (-not $SkipResourceGraph -and (Get-Module -ListAvailable -Name 'Az.ResourceGraph')) {
    Import-Module Az.ResourceGraph -ErrorAction Stop
    $resourceGraphAvailable = $true
}

foreach ($subscription in $subscriptions) {
    Write-Host "Collecting data for subscription: $($subscription.Name)"
    Set-AzContext -SubscriptionId $subscription.Id | Out-Null

    $workspaces = @(Get-AzOperationalInsightsWorkspace)

    foreach ($workspace in $workspaces) {
        $workspaceInventory.Add([pscustomobject]@{
            subscriptionName = $subscription.Name
            subscriptionId = $subscription.Id
            resourceGroup = $workspace.ResourceGroupName
            workspaceName = $workspace.Name
            location = $workspace.Location
            sku = $workspace.Sku.Name
            retentionInDays = $workspace.RetentionInDays
            resourceId = $workspace.ResourceId
        })
    }

    if ($resourceGraphAvailable) {
        $query = @"
resources
| where subscriptionId =~ '$($subscription.Id)'
| where type startswith 'microsoft.securityinsights/'
| project subscriptionId, resourceGroup, name, type, location, id
"@

        $results = @(Search-AzGraph -Query $query -First 5000)
        foreach ($result in $results) {
            $sentinelResourceInventory.Add([pscustomobject]@{
                subscriptionId = $result.subscriptionId
                resourceGroup = $result.resourceGroup
                name = $result.name
                type = $result.type
                location = $result.location
                resourceId = $result.id
            })
        }
    }
}

$subscriptions | ConvertTo-Json -Depth 10 | Set-Content -Path $subscriptionsFile
$workspaceInventory | ConvertTo-Json -Depth 10 | Set-Content -Path $workspacesFile
$sentinelResourceInventory | ConvertTo-Json -Depth 10 | Set-Content -Path $sentinelResourcesFile

$workspaceCount = $workspaceInventory.Count
$resourceCount = $sentinelResourceInventory.Count
$resourceGraphMessage = if ($resourceGraphAvailable) {
    'Resource Graph inventory collected.'
}
else {
    'Resource Graph inventory skipped because Az.ResourceGraph is not installed or SkipResourceGraph was used.'
}

$summary = @()
$summary += '# Inventory summary'
$summary += ''
$summary += "Generated: $(Get-Date -Format s)"
$summary += ''
$summary += '## Scope'
$summary += ''
$summary += "- Subscriptions scanned: $($subscriptions.Count)"
$summary += "- Log Analytics workspaces found: $workspaceCount"
$summary += "- Sentinel resources found: $resourceCount"
$summary += "- Note: $resourceGraphMessage"
$summary += ''
$summary += '## Files'
$summary += ''
$summary += "- $subscriptionsFile"
$summary += "- $workspacesFile"
$summary += "- $sentinelResourcesFile"
$summary += ''
$summary += '## Next review items'
$summary += ''
$summary += '- Identify the primary Sentinel workspace'
$summary += '- Group workspaces by region'
$summary += '- Confirm which workspaces are connected to Defender'
$summary += '- Review Sentinel resource types found through Resource Graph'
$summary += '- Compare inventory with the audit checklist'

$summary | Set-Content -Path $summaryFile

Write-Host ''
Write-Host 'Inventory export completed.'
Write-Host "Summary: $summaryFile"
Write-Host "Workspaces: $workspacesFile"
Write-Host "Sentinel resources: $sentinelResourcesFile"
Write-Host ''
Write-Host 'This script is read-only. No Azure resources were modified.'
