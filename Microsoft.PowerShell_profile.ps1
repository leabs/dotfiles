# Personal PowerShell profile for Windows devs
# Symlink/copy this file to $PROFILE (e.g., $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1)

# Line editing and history
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    $cmd = Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Parameters.ContainsKey('PredictionSource')) {
        Set-PSReadLineOption -PredictionSource History
    }
    if ($cmd -and $cmd.Parameters.ContainsKey('PredictionViewStyle')) {
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -BellStyle None
}

# Git prompt (posh-git if available)
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

# Handy aliases
Set-Alias ll Get-ChildItem
function la { Get-ChildItem -Force }
function which { param([string]$command) Get-Command $command -ErrorAction SilentlyContinue }

# Quick navigation
function cproj {
    $root = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $root) { Set-Location $root } else { Write-Warning "Not inside a git repo" }
}
function up { Set-Location .. }
function up2 { Set-Location ../.. }

# Git helpers
function gs { git status -sb }
function gl { git log --oneline --graph --decorate -20 }
function gp { git pull --rebase --autostash }
function gpf { git push --force-with-lease }
function gco { param([string]$branch) git checkout $branch }
function gcob { param([string]$branch) git checkout -b $branch }

# Refresh PATH from system + user scopes (helpful after installs)
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-Host "Path refreshed" -ForegroundColor Green
}

# Preferred editor
$env:EDITOR = "code --wait"
# Default directory
$defaultGitHub = Join-Path $env:USERPROFILE 'github'
if (Test-Path $defaultGitHub) { Set-Location $defaultGitHub }
