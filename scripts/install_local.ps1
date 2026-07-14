[CmdletBinding()]
param(
    [switch]$Development,
    [switch]$ConfigureMarketplace,
    [switch]$DryRun,
    [string]$CodexCli
)

$ErrorActionPreference = 'Stop'
$codexHome = if ($env:CODEX_HOME) {
    [System.IO.Path]::GetFullPath($env:CODEX_HOME)
} else {
    [System.IO.Path]::GetFullPath((Join-Path $env:USERPROFILE '.codex'))
}
$env:CODEX_HOME = $codexHome

if (-not $CodexCli) {
    $CodexCli = if ($env:CODEX_CLI_PATH) {
        $env:CODEX_CLI_PATH
    } else {
        (Get-Command codex -ErrorAction Stop).Source
    }
}
$CodexCli = (Get-Command $CodexCli -ErrorAction Stop).Source

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$pluginPath = Join-Path $repoRoot 'plugins/literature-workflow'
$marketplacePath = Join-Path $repoRoot '.agents/plugins/marketplace.json'
$creatorRoot = Join-Path $env:USERPROFILE '.codex/skills/.system/plugin-creator'
$python = Join-Path $env:USERPROFILE '.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
$validate = Join-Path $creatorRoot 'scripts/validate_plugin.py'
$cachebuster = Join-Path $creatorRoot 'scripts/update_plugin_cachebuster.py'
$readMarketplace = Join-Path $creatorRoot 'scripts/read_marketplace_name.py'

foreach ($required in @($pluginPath, $marketplacePath, $python, $validate, $readMarketplace)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required path missing: $required" }
}

Write-Output "CODEX_HOME=$codexHome"
Write-Output "Codex CLI: $CodexCli"

function Invoke-Step([string]$Display, [scriptblock]$Action) {
    Write-Output $Display
    if (-not $DryRun) {
        & $Action
        if ($LASTEXITCODE -ne 0) { throw "Command failed: $Display" }
    }
}

Invoke-Step "$python $validate $pluginPath" { & $python $validate $pluginPath }

if ($Development) {
    if (-not (Test-Path -LiteralPath $cachebuster)) { throw "Required path missing: $cachebuster" }
    Invoke-Step "$python $cachebuster $pluginPath" { & $python $cachebuster $pluginPath }
}

if ($DryRun) {
    $marketplaceName = 'literature-workflow'
    Write-Output "$python $readMarketplace --marketplace-path $marketplacePath"
} else {
    $marketplaceName = (& $python $readMarketplace --marketplace-path $marketplacePath).Trim()
    if ($LASTEXITCODE -ne 0 -or -not $marketplaceName) { throw 'Unable to read marketplace name.' }
}

if ($ConfigureMarketplace) {
    Invoke-Step "codex plugin marketplace add $repoRoot" { & $CodexCli plugin marketplace add $repoRoot }
}

Invoke-Step "codex plugin add literature-workflow@$marketplaceName" { & $CodexCli plugin add "literature-workflow@$marketplaceName" }
Write-Output 'Start a new Codex task to verify the updated plugin.'
