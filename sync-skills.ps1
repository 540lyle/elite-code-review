$ErrorActionPreference = 'Stop'

$RepoRoot  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SkillName = 'elite-code-review'
$Source    = Join-Path $RepoRoot 'skill'

$targets = @('.codex', '.claude')

foreach ($target in $targets) {
    $dest = "$RepoRoot\$target\skills\$SkillName"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null

    # Copy all skill content recursively
    Copy-Item -Path "$Source\*" -Destination $dest -Recurse -Force

    # Remove Codex-specific files from Claude target
    if ($target -eq '.claude') {
        Remove-Item -Path "$dest\agents" -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Synced -> $target/skills/$SkillName"
}
