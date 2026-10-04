# Messages extended deployment, following MAA Manager's deploy_mod.bat workflow.
# Usage: .\deploy_mod.ps1 | .\deploy_mod.ps1 -WhatIf | .\deploy_mod.ps1 -Remove
[CmdletBinding(SupportsShouldProcess = $true)]
param([string]$ModDirectory, [switch]$Remove)
$ErrorActionPreference = 'Stop'
$modName = 'MessagesExtended'
$sourceDirectory = Join-Path $PSScriptRoot 'mod'
$descriptorSource = Join-Path $PSScriptRoot 'descriptor.mod'

if ([string]::IsNullOrWhiteSpace($ModDirectory)) {
    $documentsDirectory = [Environment]::GetFolderPath('MyDocuments')
    if ([string]::IsNullOrWhiteSpace($documentsDirectory)) { throw 'Cannot locate the Windows Documents folder.' }
    $ModDirectory = Join-Path $documentsDirectory 'Paradox Interactive\Crusader Kings III\mod'
}
$modDirectoryPath = [IO.Path]::GetFullPath($ModDirectory).TrimEnd('\', '/')
$targetDirectory = [IO.Path]::GetFullPath((Join-Path $modDirectoryPath $modName))
$targetDescriptor = [IO.Path]::GetFullPath((Join-Path $modDirectoryPath "$modName.mod"))
if ((Split-Path -Parent $targetDirectory) -ne $modDirectoryPath -or
    (Split-Path -Leaf $targetDirectory) -ne $modName -or
    (Split-Path -Parent $targetDescriptor) -ne $modDirectoryPath) {
    throw 'Destination path containment check failed.'
}
if (-not $Remove) {
    foreach ($required in @($descriptorSource, (Join-Path $sourceDirectory 'descriptor.mod'), (Join-Path $sourceDirectory 'thumbnail.png'))) {
        if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Missing source: $required" }
    }
}

# Check ownership and links before replacing an existing installation.
if (Test-Path -LiteralPath $targetDirectory) {
    $targetItem = Get-Item -LiteralPath $targetDirectory -Force
    $existingDescriptor = Join-Path $targetDirectory 'descriptor.mod'
    if (-not $targetItem.PSIsContainer -or ($targetItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw "Refusing to replace a non-directory or linked target: $targetDirectory"
    }
    if (-not (Test-Path -LiteralPath $existingDescriptor -PathType Leaf) -or
        (Get-Content -LiteralPath $existingDescriptor -Raw -Encoding UTF8) -notmatch '(?m)^name="Messages extended"\s*$') {
        throw "Existing folder does not belong to Messages extended: $targetDirectory"
    }
    $pendingDirectories = New-Object 'System.Collections.Generic.Queue[string]'
    $pendingDirectories.Enqueue($targetDirectory)
    while ($pendingDirectories.Count -gt 0) {
        foreach ($item in Get-ChildItem -LiteralPath $pendingDirectories.Dequeue() -Force) {
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked item in old payload: $($item.FullName)" }
            if ($item.PSIsContainer) { $pendingDirectories.Enqueue($item.FullName) }
        }
    }
}
if (Test-Path -LiteralPath $targetDescriptor) {
    $descriptorItem = Get-Item -LiteralPath $targetDescriptor -Force
    if ($descriptorItem.PSIsContainer -or ($descriptorItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
        (Get-Content -LiteralPath $targetDescriptor -Raw -Encoding UTF8) -notmatch '(?m)^name="Messages extended"\s*$') {
        throw "Existing launcher descriptor does not belong to Messages extended: $targetDescriptor"
    }
}

Write-Host 'Messages extended - Mod Deployment'
Write-Host "Source: $sourceDirectory"
Write-Host "Target: $targetDirectory"
$operation = if ($Remove) { 'Remove Messages extended' } else { 'Replace Messages extended and install its descriptor' }
if ($PSCmdlet.ShouldProcess($targetDirectory, $operation)) {
    # Exact absolute destinations were checked above; never touch other mods.
    if (Test-Path -LiteralPath $targetDirectory) { Remove-Item -LiteralPath $targetDirectory -Recurse -Force }
    if (Test-Path -LiteralPath $targetDescriptor) { Remove-Item -LiteralPath $targetDescriptor -Force }
    if ($Remove) {
        Write-Host 'Messages extended removed.'
    } else {
        New-Item -ItemType Directory -Path $modDirectoryPath -Force | Out-Null
        Copy-Item -LiteralPath $sourceDirectory -Destination $targetDirectory -Recurse -Force
        $descriptorText = Get-Content -LiteralPath $descriptorSource -Raw -Encoding UTF8
        $absolutePayload = $targetDirectory.Replace('\', '/')
        $descriptorText = [regex]::Replace($descriptorText, '(?m)^path="[^"]*"', ('path="' + $absolutePayload + '"'))
        [IO.File]::WriteAllText($targetDescriptor, $descriptorText, (New-Object Text.UTF8Encoding($false)))
        Write-Host "Deployment complete: $targetDescriptor"
        Write-Host 'Enable Messages extended in your CK3 launcher playset.'
    }
}
