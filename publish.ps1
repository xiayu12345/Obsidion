$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Python = Join-Path $Root "..\mkdocs-venv\Scripts\python.exe"
& $Python "$PSScriptRoot\..\build_obsidion_mkdocs.py"
Push-Location $Root
try {
  & $Python -m mkdocs build --clean
} finally {
  Pop-Location
}
Write-Host "Built site at $Root\site"
Write-Host "Push the repository or trigger the GitHub Action to publish."
