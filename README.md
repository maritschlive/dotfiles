# Dotfiles

Personal Neovim, Kitty, and zsh configuration, including Powerlevel10k prompt settings.
Edit your live configs normally, then run this from the repository:

```sh
./update
```

This snapshots the selected configs, records additions and deletions, commits changes,
and pushes to `origin`. It also retries pending pushes when nothing has changed.
Requires Python 3, Git, and working authentication for your remote.

## Connect a remote once

Create an empty remote repository, then run:

```sh
git remote add origin <YOUR_REPO_URL>
./update
```

Use `./update --no-push` to commit locally, or `./update -m "Describe changes"`
for a custom commit message. The command works from any directory using its full path.
For a shorter command, add an alias to your `.zshrc` pointing to this repo's `update` script.

## Included files

- `$XDG_CONFIG_HOME/nvim` and `$XDG_CONFIG_HOME/kitty` (defaults to `~/.config`).
- `.zshrc` and any `.zshenv`, `.zprofile`, `.zlogin`, `.zlogout` under `${ZDOTDIR:-$HOME}`.
- `~/.p10k.zsh`, when present.

Nested Git metadata and editor temporary files are excluded. Shell history and installed
plugins are not copied. Copies of symlinked config files are stored as ordinary files.
Missing required configs stop the update; missing optional files are removed from the snapshot.
Only config files are committed by `update`; commit edits to this README or script with Git.

## Restore on another machine

Back up existing configs first, then copy `.config/nvim` and `.config/kitty` into
your config directory and the root-level zsh dotfiles into your home (or `ZDOTDIR`).
Install Neovim, Kitty, zsh, and the tools referenced in `.zshrc` separately, including
Powerlevel10k, carapace, and fzf. Your Kitty config uses JetBrainsMono Nerd Font.
Machine-specific paths in `.zshrc` may need adjustment.
