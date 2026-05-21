# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io/) and
[mise](https://mise.jdx.dev/).

**Hard-gated to Arch Linux and Ubuntu 25.10 (questing).** Anything else fails fast.

---

## Install

**Requirements:** `curl` (everything else is bootstrapped by `install.sh`).
On Arch: `sudo pacman -S --needed curl`. Ubuntu 25.10 ships curl by default.

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
| `compositor` | `niri`, `hyprland`, or `both` (default: `both`)           |

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

- **Compositor** — `niri`, `hyprland`, or `both` (GDM picks session at login).
- **Niri shell** — [DankMaterialShell (DMS)](https://danklinux.com/) (bar +
  notifications + launcher + lock), spawned by niri at startup. `dsearch` is
  removed (user uses rofi).
- **Hyprland shell** — waybar + swaync + rofi + wlogout + hyprdynamicmonitors
  (pinned v1.4.0 from upstream releases).
- **Browsers** — Google Chrome (default) + Firefox (fallback, ships with
  Ubuntu GNOME).
- **Apps** — ghostty (mkasberg installer), VSCode, Teams-for-Linux, AnyDesk,
  Remmina, gnome-boxes, HeidiSQL (+ libqt6pas dep), Piper, mpv, FileZilla,
  Wally (ZSA keyboards, with udev rules + plugdev group), nautilus, pavucontrol,
  blueman, Spotify, Discord, Obsidian, Bitwarden, GIMP, drawio (flatpak).
- **Editor** — Neovim AppImage pinned to `v0.12.2` (Ubuntu apt lags).
- **Cloud / DevOps** — Docker (official apt repo on Ubuntu, pacman on Arch) +
  compose v2 plugin, Ansible (pipx on Ubuntu, pacman on Arch), `tfswitch` /
  `tgswitch` (warrensbox binaries — they download terraform/terragrunt on
  first invocation, no separate install needed; run `tfswitch` once
  interactively to install the desired version), `eza`.
- **AI tooling** — [opencode](https://opencode.ai) + [claude](https://claude.ai)
  CLIs (upstream installers; configs in `dot_config/opencode/` and `dot_claude/`).
- **YubiKey** — `ykman` CLI + `yubikey-manager-qt` GUI + `pcscd` socket
  enabled + udev rules (`libyubikey-udev` on Ubuntu, `yubikey-manager` ships
  rules on Arch).
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

Once installed and after first niri login:

```sh
# First-run wizard (theme, wallpaper, profile picture):
dms setup

# Useful subcommands:
dms restart        # reload shell
dms update         # update to latest
```

DMS is spawned by niri itself (`spawn-at-startup "dms" "run"` in
`niri/config.kdl`); the `run_after_30-dms-systemd.sh.tmpl` script also wires
a systemd `add-wants` as a safety net. Under `hyprland` (or the hyprland
half of `compositor=both`), DMS is NOT started — hyprland uses waybar instead.

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
