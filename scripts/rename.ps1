<#
.SYNOPSIS
Renames this template from "tavern-php-template" to a project name of your choosing.
.EXAMPLE
./scripts/rename.ps1 my-new-app -Yes
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Name,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'

$OldSlug = 'tavern-php-template'
$OldSpaced = 'tavern php template'
$OldTitle = 'TAVERN Stack - Tailwindcss + React + HeroUI + Vite + Typescript'

$Root = Split-Path -Parent $PSScriptRoot
$Excludes = @('.git', 'node_modules', 'vendor', 'dist', '.idea')

if ([string]::IsNullOrWhiteSpace($Name))
{
    $Name = Read-Host 'New project name'
}

# Normalize to an npm/composer-safe slug: lowercase, non-alphanumerics collapsed to dashes.
$NewSlug = ($Name.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')

if ([string]::IsNullOrWhiteSpace($NewSlug))
{
    Write-Error 'Name must contain at least one letter or digit.'
}
if ($NewSlug -eq $OldSlug)
{
    Write-Host "Project is already named '$OldSlug'. Nothing to do."
    exit 0
}

# Human-readable variants derived from the slug.
$NewSpaced = $NewSlug -replace '-', ' '
$NewTitle = (Get-Culture).TextInfo.ToTitleCase($NewSpaced)

$Patterns = @($OldSlug, $OldSpaced, $OldTitle)

$Files = Get-ChildItem -Path $Root -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($Root.Length).TrimStart('\', '/')
    $segments = $relative -split '[\\/]'
    -not ($segments | Where-Object { $Excludes -contains $_ })
} | Where-Object {
    # Skip the rename scripts themselves - they hold the patterns as literals.
    $_.Name -notin @('rename.sh', 'rename.ps1')
} | Where-Object {
    $content = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue
    $content -and ($Patterns | Where-Object { $content.Contains($_) })
}

if (-not $Files)
{
    Write-Host "No files reference '$OldSlug'. Nothing to do."
    exit 0
}

Write-Host "Renaming '$OldSlug' -> '$NewSlug' (display: '$NewTitle') in:"
$Files | ForEach-Object { Write-Host ('  ' + $_.FullName.Substring($Root.Length).TrimStart('\', '/')) }

if (-not $Yes)
{
    $reply = Read-Host 'Proceed? [y/N]'
    if ($reply -notmatch '^(y|yes)$')
    {
        Write-Host 'Aborted.'
        exit 1
    }
}

foreach ($file in $Files)
{
    $content = Get-Content -LiteralPath $file.FullName -Raw
    # Longest/most specific pattern first so the page title isn't half-replaced.
    $content = $content.Replace($OldTitle, $NewTitle).Replace($OldSlug, $NewSlug).Replace($OldSpaced, $NewSpaced)
    [System.IO.File]::WriteAllText($file.FullName, $content)
}

Write-Host "Done. Review the diff with 'git diff' before committing."
Write-Host 'Note: the containing folder and the git remote are not renamed.'
