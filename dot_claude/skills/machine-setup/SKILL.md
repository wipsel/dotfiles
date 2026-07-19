---
name: machine-setup
description: Set up (bootstrap) this machine from the chezmoi dotfiles repo — apply configs, install dependencies, and flag what needs manual attention. Use when asked to "set it up for me", "set up this machine/PC", "bootstrap my dotfiles", "get this new machine ready", or right after cloning the dotfiles repo on a fresh box.
---

# Machine setup (chezmoi bootstrap)

Bring a machine to a working state from `git@github.com:wipsel/dotfiles.git`. chezmoi does the
mechanical work (apply + pacman install); **you are the judgment layer** — read the manifest,
verify, and produce a **Setup Report** listing everything a human must still do. The repo is
**public**: never put work secrets in it.

## Privilege boundary — read first
Package install needs `sudo pacman`; you cannot type a sudo password. For any root step, print
the exact command and ask the user to run it themselves with a leading `!` (e.g. `! chezmoi apply`),
or to run `! sudo -v` first so your own `chezmoi apply` succeeds inside the sudo timestamp.
Everything else — init, templates, user-level installs, git — you do yourself.

## Steps

1. **Preconditions.** `chezmoi --version`, `git --version`. On Arch confirm `sudo`. chezmoi is
   the one thing that must already be installed before you can help; flag it if absent.

2. **Init if needed.** If `chezmoi source-path` fails, initialize:
   `chezmoi init git@github.com:wipsel/dotfiles.git --promptDefaults`
   `--promptDefaults` skips the secret prompt (blank token) so it runs non-interactively — you
   never handle the work secret; the user pastes it later (step 7). If already initialized,
   `chezmoi git -- pull` to freshen.

3. **Preview.** `chezmoi diff` so the user sees exactly what will change (configs + the
   `install-packages.sh` script that will run).

4. **Install + apply (needs the user for sudo).** Ask the user to run `! chezmoi apply`.
   The `run_onchange_before_install-packages.sh` script installs the pacman set from
   `.chezmoidata/packages.yaml` (idempotent, `--needed`), then every config is written.
   On a non-Arch host the script only *prints* the package list to install manually.
   Verify after: `chezmoi status` (empty = clean).

5. **Audit deps against the manifest.** Read `.chezmoidata/packages.yaml`. For each pacman
   package check `pacman -Qq <p>`. Then the non-pacman groups:
   - **aur** (e.g. `brillo`): if missing and no `paru`/`yay`, flag for manual install — don't build.
   - **hyprpm** (e.g. `hy3`): `hyprpm list`; if missing, flag the exact
     `hyprpm add <url> && hyprpm enable <name>` (must match the running hyprland version; needs a session).
   - **external** (e.g. `wt`): user-level, so **you can do it**. For a `private: true` module,
     `export GOPRIVATE=github.com/wipsel` then run its `install:` command. Needs Go + SSH access
     to the private repo. Flag on failure.

6. **Fish plugins.** If `fisher` is bootstrapped, `fish -c "fisher update"` installs the
   fzf/nvm plugins. Flag if fisher isn't set up yet.

7. **Host-specific differences (the things that can't just merge).**
   - **Monitors:** if `.chezmoidata/monitors.yaml` has no entry for this hostname, hypr fell
     back to auto. From inside a running Hyprland session read `hyprctl monitors`, propose the
     exact `monitors.yaml` entry for this host, add it, `chezmoi apply`, and commit (see
     dotfiles-sync). On a truly fresh box hypr isn't running yet — do this on a second pass
     after first login.
   - **Secret token:** tell the user to paste this box's value into
     `~/.config/chezmoi/chezmoi.toml` under `[data]`, then `chezmoi apply`. The value stays off git.

8. **Setup Report.** End with:
   ```
   ✓ Applied:   <n> files
   ✓ Installed: <pacman packages present>
   ✓ wt:        <installed / failed — reason>
   ⚠ Manual:    <aur + hyprpm items, with exact commands>
   ⚠ Host:      <monitor profile to add, or "none">
   ⚠ Secret:    <paste token into [data], or "set">
   ```

Commit any repo changes setup produced (e.g. a new monitor profile) per the dotfiles-sync
convention, and leave pushing to the user.
