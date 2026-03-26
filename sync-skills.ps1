$ErrorActionPreference = 'Stop'

$RepoRoot  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SkillName = 'elite-code-review'
$Source    = Join-Path $RepoRoot 'skill'

$targets = @('.codex', '.claude')

foreach ($target in $targets) {
    $dest = "$RepoRoot\$target\skills\$SkillName"

    # Create shared subdirectories
    New-Item -ItemType Directory -Force -Path "$dest\examples" | Out-Null
    New-Item -ItemType Directory -Force -Path "$dest\scripts"  | Out-Null

    # Core skill file
    Copy-Item "$Source\SKILL.md" -Destination $dest -Force

    # Supporting files
    Copy-Item "$Source\examples\strong_review.md" -Destination "$dest\examples" -Force
    Copy-Item "$Source\examples\weak_review.md"   -Destination "$dest\examples" -Force
    Copy-Item "$Source\scripts\detect_changes.sh"  -Destination "$dest\scripts"  -Force

    # Codex-specific files
    if ($target -eq '.codex') {
        New-Item -ItemType Directory -Force -Path "$dest\agents" | Out-Null
        Copy-Item "$Source\agents\openai.yaml" -Destination "$dest\agents" -Force
    }

    Write-Host "Synced -> $target/skills/$SkillName"
}
