# ghost

A zero-footprint Nix flake that injects hidden IDE and AI workspace configurations (`.vscode`, `.claude`, etc.) into any repository and automatically excludes them from Git.

## Usage

Run directly inside any project directory without installing anything globally:

```bash
# Inject all configured templates
nix run github:ThanhDang13/ghost

# Inject a specific template (e.g., templates/vscode -> .vscode/)
nix run github:ThanhDang13/ghost#vscode
```

*(Optional)* Register a local alias for shorter commands:

```bash
nix registry add ghost github:ThanhDang13/ghost
nix run ghost#vscode
```

## Structure

```text
ghost/
├── flake.nix
└── templates/
    └── vscode/
        ├── settings.json
        └── launch.json
```

### Adding New Templates

1. Create a new directory under `templates/<name>` (e.g., `templates/claude`).
2. Add your configuration files inside it.
3. Track the new directory with Git (`git add templates/<name>`).

The flake automatically discovers all directories in `templates/` and exposes them as `#<name>` apps.

## Post-Injection Setup

Files containing `"PLACEHOLDER"` (such as workspace-specific paths in `.vscode/settings.json`) are meant to be replaced locally after injection. Since injected directories are automatically appended to `.gitignore`, your local overrides will never pollute the repository's Git history.
