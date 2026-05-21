# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io/) and
[mise](https://mise.jdx.dev/).

**Hard-gated to Arch Linux and Ubuntu 25.10 (questing).** Anything else fails fast.

---

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/DanielePeruzzi97/dotfiles/main/install.sh | bash
```

On first run `chezmoi init` asks for:

| prompt       | what it sets                                              |
|--------------|-----------------------------------------------------------|
| `name`       | git `[user].name`                                         |
| `email`      | git `[user].email`                                        |
| `signingkey` | git `[user].signingkey` (leave blank to skip GPG signing) |
| `profile`    | `minimal` or `workstation` (default: `workstation`)       |

After install, `~/.config/chezmoi/chezmoi.toml` holds the answers — re-running
`chezmoi apply` does not re-prompt.

---

## Profiles

### `minimal`
Headless / server-style box. CLI only.

- `zsh`, `git`, `tmux`, `curl`, `wget`, `fzf`, `ripgrep`, `zoxide`, `fd`, `unzip`
- `mise` + every dev tool from `dot_config/mise/config.toml`
- `oh-my-zsh` + plugins, `tpm` (via `.chezmoiexternal.toml`)

### `workstation` (default)
Everything in `minimal` plus a full Wayland desktop:

- **Compositors** — Niri **and** Hyprland installed side by side, GDM picks
  session at login.
- **Shell** — [DankMaterialShell (DMS)](https://danklinux.com/), enabled as a
  user systemd unit and tied to `niri.service` via `add-wants`.
- **Apps** — rofi, waybar, nautilus, pavucontrol, blueman, mpv, drawio
  (flatpak), Spotify, Obsidian, Bitwarden, GIMP, DBeaver.
- **k8s** (via mise) — `kubectl`, `helm`, `k9s`, `talosctl`, `kubeseal`.

---

## Layout

```
.chezmoi.toml.tmpl                         # prompts + profile + distro detection
.chezmoidata/packages.yaml                 # declarative pkg lists per profile + distro
.chezmoiexternal.toml                      # oh-my-zsh, zsh plugins, tpm
.chezmoiignore.tmpl                        # what to keep out of $HOME (per profile)
.chezmoiscripts/
  run_before_00-distro-guard.sh.tmpl       # fail closed on unsupported OS
  run_before_05-install-packages.sh.tmpl   # apt / pacman / paru / flatpak
  run_before_10-ensure-mise.sh             # install mise if missing
  run_onchange_after_50-mise-install.sh.tmpl
  run_onchange_after_60-install-fonts.sh
  run_after_30-dms-systemd.sh.tmpl         # enable dms + add-wants niri
  run_after_70-change-shell.sh             # chsh -> zsh
  run_after_80-hyprland-plugins.sh.tmpl    # hyprpm (workstation only)
  run_after_81-systemd-services.sh.tmpl    # enable hypridle/hyprpaper/...
  run_onchange_after_71-tmux-plugins.sh.tmpl
dot_config/                                # ~/.config payload
dot_gitconfig.tmpl                         # personal git identity (+ work include)
dot_zshrc, dot_tmux.conf
install.sh                                 # curl-friendly bootstrap (<100 LOC)
```

`mise` config lives in `dot_config/mise/config.toml` and is the single source
of truth for languages + dev/cloud CLIs. Edit it directly.

---

## Updating

```sh
chezmoi update              # pull repo + re-apply
chezmoi cd                  # jump into the source dir
chezmoi diff                # preview pending changes
```

`autoCommit = true` + `autoPush = true` are enabled in
`.chezmoi.toml.tmpl` — local edits to managed files are committed and pushed
automatically by chezmoi.

---

## Private dotfiles (separate repo)

Secrets, work git overrides (`~/.gitconfig-work`), private mise configs, etc.
live in [`dotfiles_private`](https://github.com/DanielePeruzzi97/dotfiles_private)
and are installed with a separate one-liner. This repo contains **zero
secrets, zero encrypted blobs, zero YubiKey logic**.

---

## DMS — manual bits

Once installed and after first `niri-session` login:

```sh
# (run_after_30-dms-systemd already does this, kept here for reference)
systemctl --user enable --now dms.service
systemctl --user add-wants niri.service dms.service

# First-run wizard (theme, wallpaper, profile picture):
dms setup

# Useful subcommands:
dms restart        # reload shell
dms update         # update to latest
```

Do **not** add `spawn-at-startup "dms" "run"` to `niri/config.kdl` — the
systemd unit handles startup and avoids double-launch.

---

## Forking

1. Fork on GitHub.
2. Override the install one-liner:

   ```sh
   DOTFILES_REPO="<your-user>/dotfiles" \
     curl -fsSL https://raw.githubusercontent.com/<your-user>/dotfiles/main/install.sh | bash
   ```
3. Adjust `.chezmoidata/packages.yaml` to taste.
4. If you don't use `omnys.lan`, edit the `includeIf` block at the bottom of
   `dot_gitconfig.tmpl`.

---

## License

MIT — do whatever you want, no warranty.
