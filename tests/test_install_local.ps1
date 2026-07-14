$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts/install_local.ps1'
$expectedCodexHome = Join-Path $env:USERPROFILE '.codex'
$codexCli = (Get-Command powershell.exe -ErrorAction Stop).Source
$savedCodexHome = $env:CODEX_HOME
try {
    Remove-Item Env:CODEX_HOME -ErrorAction SilentlyContinue
    $output = & $scriptPath -DryRun -CodexCli $codexCli 2>&1 | Out-String
} finally {
    $env:CODEX_HOME = $savedCodexHome
}
if (-not $?) { throw "Dry run failed: $output" }
foreach ($required in @(
    'validate_plugin.py',
    "CODEX_HOME=$expectedCodexHome",
    "Codex CLI: $codexCli",
    'codex plugin add',
    'literature-workflow@literature-workflow',
    'Start a new Codex task'
)) {
    if ($output -notmatch [regex]::Escape($required)) { throw "Missing output: $required`n$output" }
}
if ($output -match 'Copy-Item') { throw 'Direct personal-skill copying is forbidden.' }
Write-Output 'PASS: install_local dry run contract'
