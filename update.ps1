# Managed-Source: brainboxemb/tool.git-project/bootstrap/consumer-update.ps1
# Managed-Source-Version: 0.2.11
# Managed-Source-Revision: 219b0f055e6f82bafb3386cfa2719acf54b79f0c
# Managed-Local-Patch: none
param(
    [ValidateSet("update", "status")]
    [string] $Command = "update"
)

$ErrorActionPreference = "Stop"
$ToolPath = "tools/tool.git-project"
$Root = (& git rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $Root) { throw "Run update.ps1 from inside a Git repository." }
$Root = $Root.Trim()
$Tool = Join-Path $Root "$ToolPath/git-project.ps1"
if (-not (Test-Path $Tool -PathType Leaf)) { throw "tool.git-project is not initialized. Run .\bootstrap.ps1 first." }
& $Tool $Command -RepoRoot $Root
if ($LASTEXITCODE -ne 0) { throw "Generic project $Command failed." }
