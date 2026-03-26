$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Point git to the committed hooks directory
git config core.hooksPath '.githooks'
Write-Host "Configured core.hooksPath -> .githooks"

# Run initial skill sync
& "$RepoRoot\sync-skills.ps1"

Write-Host ""
Write-Host "Setup complete. Skills will auto-sync on checkout and pull."
