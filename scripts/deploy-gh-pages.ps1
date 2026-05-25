param(
  [switch]$NoPush,
  [switch]$SkipInstall,
  [switch]$AllowDirty,
  [string]$Message
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$RepoRootGit = $RepoRoot -replace "\\", "/"
$DeployRoot = Join-Path $RepoRoot ".deploy-worktree"
$WorktreePath = Join-Path $DeployRoot "gh-pages"
$SiteDir = Join-Path $RepoRoot "_site"

function Invoke-GitAt {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$GitArgs
  )

  $SafePath = $Path -replace "\\", "/"
  & git -C $Path -c "safe.directory=$SafePath" @GitArgs
  if ($LASTEXITCODE -ne 0) {
    throw "git $($GitArgs -join ' ') failed with exit code $LASTEXITCODE"
  }
}

function Test-GitRef {
  param(
    [string]$Ref
  )

  & git -C $RepoRoot -c "safe.directory=$RepoRootGit" show-ref --verify --quiet $Ref
  return $LASTEXITCODE -eq 0
}

function Clear-DirectoryContents {
  param(
    [string]$Path,
    [string]$ExpectedParent
  )

  $ResolvedPath = (Resolve-Path -LiteralPath $Path).Path
  $ResolvedParent = (Resolve-Path -LiteralPath $ExpectedParent).Path

  if (-not $ResolvedPath.StartsWith($ResolvedParent, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to clear unexpected path: $ResolvedPath"
  }

  Get-ChildItem -LiteralPath $ResolvedPath -Force |
    Where-Object { $_.Name -ne ".git" } |
    Remove-Item -Recurse -Force
}

Set-Location $RepoRoot

$CurrentBranch = (Invoke-GitAt $RepoRoot rev-parse --abbrev-ref HEAD).Trim()
if ($CurrentBranch -ne "main") {
  throw "Publish from main only. Current branch: $CurrentBranch"
}

$Status = Invoke-GitAt $RepoRoot status --porcelain
if ($Status -and -not $AllowDirty) {
  throw "Working tree is not clean. Commit or stash changes before publishing, or pass -AllowDirty for a local dry run."
}

$env:BUNDLE_APP_CONFIG = Join-Path $RepoRoot ".bundle"
$env:BUNDLE_PATH = Join-Path $RepoRoot "vendor/bundle"
$env:BUNDLE_BIN = Join-Path $RepoRoot "vendor/bundle/bin"
$env:BUNDLE_DISABLE_SHARED_GEMS = "true"
$env:BUNDLE_VERSION = "system"
$env:RUBYLIB = (@($PSScriptRoot, $env:RUBYLIB) | Where-Object { $_ }) -join ";"
$env:RUBYOPT = (@("-rresolv-replace", "-rjekyll_ruby33_compat", $env:RUBYOPT) | Where-Object { $_ }) -join " "

if (-not $SkipInstall) {
  bundle install
}

bundle exec jekyll build
if ($LASTEXITCODE -ne 0) {
  throw "Jekyll build failed with exit code $LASTEXITCODE"
}

$IndexPath = Join-Path $SiteDir "index.html"
if (-not (Test-Path -LiteralPath $IndexPath)) {
  throw "Build did not produce _site/index.html"
}

Copy-Item -LiteralPath (Join-Path $RepoRoot "CNAME") -Destination (Join-Path $SiteDir "CNAME") -Force
New-Item -ItemType File -Path (Join-Path $SiteDir ".nojekyll") -Force | Out-Null

if (-not (Test-Path -LiteralPath $DeployRoot)) {
  New-Item -ItemType Directory -Path $DeployRoot | Out-Null
}

if (-not (Test-Path -LiteralPath $WorktreePath)) {
  if (Test-GitRef "refs/heads/gh-pages") {
    Invoke-GitAt $RepoRoot worktree add $WorktreePath gh-pages
  } elseif (Test-GitRef "refs/remotes/origin/gh-pages") {
    Invoke-GitAt $RepoRoot worktree add -b gh-pages $WorktreePath origin/gh-pages
  } else {
    Invoke-GitAt $RepoRoot worktree add --detach $WorktreePath HEAD
    Invoke-GitAt $WorktreePath switch --orphan gh-pages
  }
} else {
  Invoke-GitAt $WorktreePath switch gh-pages
}

Clear-DirectoryContents -Path $WorktreePath -ExpectedParent $DeployRoot
Get-ChildItem -LiteralPath $SiteDir -Force | Copy-Item -Destination $WorktreePath -Recurse -Force

Invoke-GitAt $WorktreePath add -A
$PublishStatus = Invoke-GitAt $WorktreePath status --porcelain
if (-not $PublishStatus) {
  Write-Host "No changes to publish."
  exit 0
}

if (-not $Message) {
  $SourceRevision = (Invoke-GitAt $RepoRoot rev-parse --short HEAD).Trim()
  $Message = "Deploy site from $SourceRevision"
}

Invoke-GitAt $WorktreePath commit -m $Message

if ($NoPush) {
  Write-Host "Built and committed gh-pages locally. Skipped push because -NoPush was supplied."
} else {
  Invoke-GitAt $WorktreePath push origin gh-pages
  Write-Host "Published gh-pages to origin."
}
