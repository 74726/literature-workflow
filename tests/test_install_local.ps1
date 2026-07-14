$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts/install_local.ps1'
$output = & $scriptPath -DryRun 2>&1 | Out-String
if (-not $?) { throw "Dry run failed: $output" }
foreach ($required in @('validate_plugin.py', 'codex plugin add', 'literature-workflow@literature-workflow', 'Start a new Codex task')) {
    if ($output -notmatch [regex]::Escape($required)) { throw "Missing output: $required`n$output" }
}
if ($output -match 'Copy-Item') { throw 'Direct personal-skill copying is forbidden.' }
Write-Output 'PASS: install_local dry run contract'
