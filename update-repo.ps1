param(
    [ValidateSet("update", "status")]
    [string] $Mode = "update"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git was not found in PATH."
}

$RootOutput = & git rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or -not $RootOutput) {
    throw "Run update-repo.ps1 from inside a Git repository."
}
$Root = ($RootOutput | Select-Object -First 1).Trim()

$ScadTool = Join-Path $Root "tools/tool.scad-project/scad-project.ps1"
if (-not (Test-Path -LiteralPath $ScadTool -PathType Leaf)) {
    throw "tool.scad-project is not initialized. Run .\bootstrap.ps1 first."
}

$CommandName = if ($Mode -eq "status") { "repo-status" } else { "repo-update" }
$ProjectFile = Join-Path $Root "project.yml"

& $ScadTool --project $ProjectFile $CommandName
if ($LASTEXITCODE -ne 0) {
    throw "SCAD repository $Mode failed."
}
