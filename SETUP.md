# Dotfiles — setup & conventions

Managed with [chezmoi](https://chezmoi.io). Source of truth: `git@github.com:wipsel/dotfiles.git`.
This repo is **public** — no work secrets, ever (see *Secrets*).

## New machine — the short version
1. Install prerequisites: Claude Code, `chezmoi`, `git`. On Arch: `sudo pacman -S chezmoi git`.
2. `chezmoi init git@github.com:wipsel/dotfiles.git`
   (prompts once for a secret token — leave it blank to set it later).
3. Open Claude Code in a terminal and say: **"set it up for me."**
   Claude runs the `machine-setup` skill — applies configs, drives the package install, installs
   `wt`, and hands back a report of anything left to do by hand (AUR packages, the `hy3` hypr
   plugin, this box's monitor layout, the secret token).

Package install needs `sudo`; Claude can't type your password, so it will ask you to run the
`chezmoi apply` (or `sudo pacman`) step yourself with a leading `!`.

## What lives where
- **Configs** — `dot_config/…`, `dot_claude/…` (chezmoi source layout).
- **Dependencies** — `.chezmoidata/packages.yaml` (declarative). The pacman groups install on
  `chezmoi apply` via `run_onchange_before_install-packages.sh.tmpl`; `aur` / `hyprpm` /
  `external` tools are *reported* by the setup skill, not force-installed.
- **Per-host monitors** — `.chezmoidata/monitors.yaml`, keyed by hostname. Add a new host from
  `hyprctl monitors`.
- **Per-machine data** — `.chezmoi.toml.tmpl` → generates local `~/.config/chezmoi/chezmoi.toml`
  on `chezmoi init`; never committed.

## Secrets
Secret values live per-machine in `~/.config/chezmoi/chezmoi.toml` under `[data]` and are read by
templates via their data key. The repo holds only the template. `.chezmoiignore` guards the
Claude Code secrets and work-specific config out of this public repo. Upgrading to `age` / `pass`
is a one-line template change.

## Day to day — the `dotfiles-sync` skill
- Pull: `chezmoi update`.
- Save a local edit: `chezmoi re-add` (Claude's `settings.json` is the exception: edit `dot_claude/modify_settings.json`) → commit (convention below) → push only when you choose.
- See drift: `chezmoi status` / `chezmoi diff`.

## Commit convention
```
<area>: <what changed>

Why: <reason>
Machine: <hostname>   # only when host-specific
```
Small commits, imperative subjects, always a *why*.
