param(
  [int]$Port = 4000,
  [switch]$SkipInstall
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

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

bundle exec jekyll serve --host 127.0.0.1 --port $Port --livereload
