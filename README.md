# Dotfiles by OS

Clone this repo and point your config files at it so you can `git pull` and keep getting updates, instead of copy/pasting static snippets. Dotfiles are organized per platform so you can install only what you need.

## Layout
- `common/`: Shared Git config, global gitignore, and gitattributes.
- `windows/`: Git config, global gitignore, editorconfig, PowerShell profile, and `.gitconfig.local.example`.
- `linux/`: A lightweight `.bashrc` starter with a few aliases and history tweaks.
- `macos/`: A lightweight `.zshrc` starter with aliases and Homebrew path loading.

## One-shot bootstrap (all platforms)
From the repo root, let the script detect your OS (macOS/Linux/Windows under MSYS/WSL) and symlink the common + OS-specific files into your home directory:
```bash
./bootstrap.sh
```
If you get a permission error, make it executable first:
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## Manual setup: Windows (PowerShell)
1) Clone the repo:
```pwsh
git clone https://github.com/steve/dotfiles.git $HOME\dotfiles
Set-Location $HOME\dotfiles
```

2) Symlink the shared Git files (from `common/`) and Windows-specific files so updates flow automatically:
```pwsh
$home = $env:USERPROFILE
New-Item -ItemType SymbolicLink -Path $home\.gitconfig -Target (Resolve-Path common/.gitconfig) -Force
New-Item -ItemType SymbolicLink -Path $home\.gitconfig.local -Target (Resolve-Path common/.gitconfig.local.example) -Force   # edit this with your info
New-Item -ItemType SymbolicLink -Path $home\.gitignore_global -Target (Resolve-Path common/.gitignore_global) -Force
New-Item -ItemType SymbolicLink -Path $home\.gitattributes -Target (Resolve-Path common/.gitattributes) -Force
New-Item -ItemType SymbolicLink -Path $home\.editorconfig -Target (Resolve-Path windows/.editorconfig) -Force
```

If symlinks are blocked (for example, if Developer Mode is off), copy instead:
```pwsh
Copy-Item common/.gitconfig "$home\.gitconfig" -Force
Copy-Item common/.gitconfig.local.example "$home\.gitconfig.local" -Force
Copy-Item common/.gitignore_global "$home\.gitignore_global" -Force
Copy-Item common/.gitattributes "$home\.gitattributes" -Force
Copy-Item windows/.editorconfig "$home\.editorconfig" -Force
```

3) Add your actual Git identity in the local override:
Edit `$home\.gitconfig.local` that you just created.

4) Install the PowerShell profile (it will start new shells in `$env:USERPROFILE\github` if that folder exists):
```pwsh
$profileDir = Split-Path $PROFILE
New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
New-Item -ItemType Directory -Path "$env:USERPROFILE\github" -Force | Out-Null
Copy-Item windows/Microsoft.PowerShell_profile.ps1 $PROFILE -Force
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   # allows the profile to run
```

5) (Optional) Install `posh-git` for a richer prompt:
```pwsh
Install-Module posh-git -Scope CurrentUser
```

Keep the repo around and run `git pull` occasionally to grab updates, then open a new PowerShell session.

## Manual setup: Linux (Bash)
1) Clone the repo and change into it.
2) Symlink the shared Git settings and Bash profile so updates pull through (copy if you prefer a static file):
```bash
ln -sf "$(pwd)/common/.gitconfig" ~/.gitconfig
ln -sf "$(pwd)/common/.gitconfig.local.example" ~/.gitconfig.local   # edit this with your info
ln -sf "$(pwd)/common/.gitignore_global" ~/.gitignore_global
ln -sf "$(pwd)/common/.gitattributes" ~/.gitattributes
ln -sf "$(pwd)/linux/.bashrc" ~/.bashrc
# or: cp the files instead of linking
```
3) Add any machine-specific tweaks in `~/.bashrc.local` (loaded automatically if it exists).
4) Keep the repo and run `git pull` occasionally to receive updates.

## Manual setup: macOS (Zsh)
1) Clone the repo and change into it.
2) Symlink the shared Git settings and Zsh profile so updates pull through (copy if you prefer a static file):
```bash
ln -sf "$(pwd)/common/.gitconfig" ~/.gitconfig
ln -sf "$(pwd)/common/.gitconfig.local.example" ~/.gitconfig.local   # edit this with your info
ln -sf "$(pwd)/common/.gitignore_global" ~/.gitignore_global
ln -sf "$(pwd)/common/.gitattributes" ~/.gitattributes
ln -sf "$(pwd)/macos/.zshrc" ~/.zshrc
# or: cp the files instead of linking
```
3) Add any machine-specific tweaks in `~/.zshrc.local` (loaded automatically if it exists).
4) Keep the repo and run `git pull` occasionally to receive updates.
5) Optional: install Oh My Zsh, Powerlevel10k, and plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) to enable the theme and extras:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
