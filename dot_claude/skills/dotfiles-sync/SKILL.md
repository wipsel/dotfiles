---
name: dotfiles-sync
description: Keep this machine's dotfiles in sync with the chezmoi repo — pull upstream changes, capture a local config edit back into the repo with a clear commit, or report drift. Use when asked to "sync my dotfiles", "pull my config", "save/commit this config change", "what config has drifted", "chezmoi status/diff", or after editing any tracked config.
---

# Dotfiles sync (day-to-day chezmoi)

Source of truth: `git@github.com:wipsel/dotfiles.git` at `~/.local/share/chezmoi`. The repo is
**public** — keep work secrets out (they live per-machine in `~/.config/chezmoi/chezmoi.toml`
under `[data]`, guarded by `.chezmoiignore`). **Default git autonomy: commit locally, never
push unless the user asks** (pushing to a public remote is an outward action to confirm).

## Pull — bring this machine up to date
- `chezmoi update -v` pulls `origin/master` and applies it. Summarize what changed.
- If it would overwrite a local edit, stop, show `chezmoi diff`, and ask before overwriting.

## Capture — a local config change → the repo
1. `chezmoi re-add` (or `chezmoi add <path>` for a new file) pulls the live edit into source.
   `~/.claude/settings.json` is the exception: a `modify_` script manages only some of its keys,
   so `re-add` skips it — capture a settings change by editing `dot_claude/modify_settings.json`.
2. Review: `chezmoi diff` and `git -C ~/.local/share/chezmoi diff`.
3. Commit with the convention below. **Do not push** — say it's committed locally and offer to
   push if they want.

## Status / doctor — see what's out
- `chezmoi status` (empty = clean), `chezmoi diff` for drift, `chezmoi doctor` for health.
- Manifest audit: read `.chezmoidata/packages.yaml`; report any declared package now missing
  (`pacman -Qq`) and any host gap (no `.chezmoidata/monitors.yaml` entry for this hostname).

## Commit convention
One small commit per change; a subject a human skims, a body that says *why*:
```
<area>: <what changed>

Why: <reason it changed>
Machine: <hostname>        # only when the change is host-specific
```
`<area>` = the config touched (fish, hypr, waybar, nvim, claude, packages, monitors, …).
Imperative, specific subjects — never "update config". Never leak conversation or prompt
context into the message.

## Where things belong (so a change lands mergeably)
- **A new secret** → value into `~/.config/chezmoi/chezmoi.toml [data]` (never the repo); read it
  in a template via its data key. The repo holds only the template.
- **A monitor / hardware difference** → `.chezmoidata/monitors.yaml`, keyed by hostname — not
  the hypr template.
- **A new dependency** → add it to `.chezmoidata/packages.yaml` (right group: core / desktop /
  aur / hyprpm / external). The pacman groups auto-install on the next `chezmoi apply`.
