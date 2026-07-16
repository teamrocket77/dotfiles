# Dotfiles

Personal macOS config, managed with nix-darwin + home-manager on the personal
machine and sourced directly from `~/.config` on work/non-Nix machines.

## Shell bootstrap

Shell behavior lives in `shell/*` (glob-sourced, in order). There are two
entrypoints that do the sourcing — pick the one matching the machine:

| Entrypoint      | Machine            | Sources                |
| --------------- | ------------------ | ---------------------- |
| `nix.zsh`       | personal / Nix     | `~/dotfiles/shell/*`   |
| `work-init.sh`  | work / non-Nix     | `~/.config/shell/*`    |

To use it on a work machine, source it from `~/.zshrc`:

```sh
[ -f ~/.config/work-init.sh ] && source ~/.config/work-init.sh
```

Notes:

- **zsh only.** `work-init.sh` uses zsh glob qualifiers (`*(.N)`); do not source
  it from bash/sh. It is meant to be *sourced*, not executed — the shebang is
  cosmetic.
- **First run clones plugins.** Sourcing pulls `shell/env.sh`, which git-clones
  zsh-autosuggestions and zsh-syntax-highlighting into `~/zsh`. Idempotent after
  the first run.

### Machine-local secrets

`shell/env.sh` sources `~/personal.sh` early if it exists. Put machine-specific
secrets and auth (API keys, tokens, work AWS/Okta helpers) there — it is not
tracked in this repo — rather than hardcoding them in `~/.zshrc`.

## Mounting shared drives via UTM

```sh
mkdir <mnt_dir>
sudo mount -t 9p -o trans=virtio share <mnt_dir> -oversion=9p2000.L
```
