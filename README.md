# Dotfiles for Windows

A small, Windows-friendly dotfiles set tuned for Git + PowerShell. Use it as-is or as a starting point for your own setup.

## What's here
- `.gitconfig`: sensible Git defaults (LF by default, VS Code as editor, prune on fetch, rerere, aliases, etc.) with placeholders; includes `~/.gitconfig.local` for your real name/email.
- `.gitignore_global`: global ignores for OS cruft, editor artifacts, logs, and `node_modules/` (also ignores `.gitconfig.local`).
- `.gitattributes`: normalizes line endings (LF default; CRLF for PowerShell/CMD scripts) and marks binaries/lockfiles.
- `.editorconfig`: consistent whitespace/newlines (LF, final newline, trim trailing space; 4-space default, 2-space for JSON/YAML/MD).
- `Microsoft.PowerShell_profile.ps1`: PSReadLine tweaks, optional posh-git prompt, git helpers, PATH refresh, handy aliases.

## Get started (PowerShell)
1) Clone the repo:
```pwsh
git clone https://github.com/steve/dotfiles.git $HOME\dotfiles
Set-Location $HOME\dotfiles
```

2) Copy (or symlink) the dotfiles into place. Copying is simplest:
```pwsh
$home = $env:USERPROFILE
Copy-Item .gitconfig "$home\.gitconfig" -Force
Copy-Item .gitconfig.local.example "$home\.gitconfig.local" -Force   # edit this with your info
Copy-Item .gitignore_global "$home\.gitignore_global" -Force
Copy-Item .gitattributes "$home\.gitattributes" -Force
Copy-Item .editorconfig "$home\.editorconfig" -Force
```

3) Add your actual Git identity in the local override (keeps personal info out of the repo):
Edit `$home\.gitconfig.local` that you just copied.

4) Install the PowerShell profile (it will start new shells in `$env:USERPROFILE\github` if that folder exists):
```pwsh
$profileDir = Split-Path $PROFILE
New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
New-Item -ItemType Directory -Path "$env:USERPROFILE\github" -Force | Out-Null
Copy-Item Microsoft.PowerShell_profile.ps1 $PROFILE -Force
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   # allows the profile to run
```

5) (Optional) Symlink instead of copy to keep updates in sync:
```pwsh
New-Item -ItemType SymbolicLink -Path $HOME\.gitconfig -Target (Resolve-Path .gitconfig) -Force
New-Item -ItemType SymbolicLink -Path $HOME\.gitignore_global -Target (Resolve-Path .gitignore_global) -Force
New-Item -ItemType SymbolicLink -Path $HOME\.gitattributes -Target (Resolve-Path .gitattributes) -Force
New-Item -ItemType SymbolicLink -Path $HOME\.editorconfig -Target (Resolve-Path .editorconfig) -Force
New-Item -ItemType SymbolicLink -Path $PROFILE -Target (Resolve-Path Microsoft.PowerShell_profile.ps1) -Force
```

6) (Optional) Install `posh-git` for a richer prompt:
```pwsh
Install-Module posh-git -Scope CurrentUser
```

After copying/symlinking, open a new PowerShell session and you’re set.
