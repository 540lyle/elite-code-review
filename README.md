# Elite Code Review Skill

A rigorous, high-signal code review skill that works with both **Codex** and **Claude Code**.

## Quick Start

```powershell
git clone <repo-url>
cd elite-code-review
powershell .\setup.ps1
```

That's it. The setup script wires in git hooks and runs the initial sync. From then on, every `git checkout` (branch switch) and `git pull` automatically distributes the skill to both tools.

## How It Works

Both Codex and Claude Code discover skills from convention-based directories, but in different locations:

| Tool        | Reads from                          | Invoked with            |
|-------------|-------------------------------------|-------------------------|
| Codex       | `.codex/skills/<name>/SKILL.md`     | `$elite-code-review`    |
| Claude Code | `.claude/skills/<name>/SKILL.md`    | `/elite-code-review`    |

Both tools use the same `SKILL.md` format (YAML frontmatter + markdown), so a single source file works for both. This repo keeps one canonical copy in `skill/` and distributes it automatically.

### Repo Structure

```
skill/                        ← single source of truth
├── SKILL.md                  ← skill definition (shared)
├── agents/
│   └── openai.yaml           ← Codex-specific agent config
├── examples/
│   ├── strong_review.md      ← example of a good review
│   └── weak_review.md        ← example of a weak review
└── scripts/
    └── detect_changes.sh     ← helper to find the active diff

.githooks/                    ← git hooks (committed)
├── post-checkout             ← auto-syncs on branch switch
└── post-merge                ← auto-syncs on pull

sync-skills.ps1               ← copies skill/ → .codex/ + .claude/
setup.ps1                     ← one-time setup: hooks + initial sync
```

The `.codex/skills/` and `.claude/skills/` directories are **gitignored** — they are generated locally by the sync script and never committed.

### What `setup.ps1` Does

1. Sets `core.hooksPath` to `.githooks` so git uses the committed hooks
2. Runs `sync-skills.ps1` to perform the initial file distribution

### What `sync-skills.ps1` Does

1. Copies `skill/` contents into `.codex/skills/elite-code-review/`
2. Copies `skill/` contents into `.claude/skills/elite-code-review/` (excluding `agents/openai.yaml`, which is Codex-specific)

## Contributing

### Editing the Skill

All changes go in the `skill/` directory. Never edit files under `.codex/skills/` or `.claude/skills/` directly — they are overwritten on every sync.

- **`skill/SKILL.md`** — the skill definition. Frontmatter fields `name` and `description` are shared by both tools. Claude Code supports additional frontmatter fields (like `allowed-tools`, `context`, `model`) that Codex will ignore.
- **`skill/agents/openai.yaml`** — Codex-specific agent metadata. Claude Code ignores this file.
- **`skill/examples/`** — example outputs referenced by the skill instructions.
- **`skill/scripts/`** — helper scripts used during review.

After editing, run the sync manually to test locally:

```powershell
powershell .\sync-skills.ps1
```

Or just commit and the hooks will sync on your next checkout.

### Adding Support for Another Tool

To add a new tool that also uses `SKILL.md`:

1. Add a new target entry in `sync-skills.ps1`
2. Add the generated directory to `.gitignore`
3. Copy any tool-specific files (like `agents/openai.yaml` for Codex) conditionally

### Requirements

- Git
- PowerShell 5.1+ (included with Windows 10/11) — required for sync; hooks silently no-op on non-Windows
