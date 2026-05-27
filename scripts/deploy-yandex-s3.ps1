# Deploy static site to Yandex Object Storage (S3-compatible)
# Requires: pip install awscli, aws configure --profile yc
# Config: scripts/yandex-deploy-config.local.ps1

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$localConfig = Join-Path $PSScriptRoot 'yandex-deploy-config.local.ps1'

if (Test-Path $localConfig) {
  . $localConfig
}

$bucket = if ($env:YC_BUCKET) { $env:YC_BUCKET } else { $YcBucket }
$endpoint = if ($env:YC_ENDPOINT) { $env:YC_ENDPOINT } else { $YcEndpoint }
$profile = if ($env:YC_PROFILE) { $env:YC_PROFILE } else { $YcProfile }

if (-not $bucket) {
  Write-Host 'Set YC_BUCKET or create yandex-deploy-config.local.ps1' -ForegroundColor Red
  exit 1
}
if (-not $endpoint) {
  $endpoint = 'https://storage.yandexcloud.net'
}

$excludes = @(
  '--exclude', '.git/*',
  '--exclude', '.github/*',
  '--exclude', '.vscode/*',
  '--exclude', '.cursor/*',
  '--exclude', 'scripts/*',
  '--exclude', 'drive-archive/*',
  '--exclude', 'docs/*',
  '--exclude', '*.md',
  '--exclude', 'clone.ps1',
  '--exclude', '.gitignore',
  '--exclude', 'CONTEXT.md'
)

$profileArg = @()
if ($profile) {
  $profileArg = @('--profile', $profile)
}

Write-Host "Deploy to s3://$bucket ($endpoint)" -ForegroundColor Cyan

$args = @(
  's3', 'sync', $repoRoot, "s3://$bucket",
  '--endpoint-url', $endpoint,
  '--delete'
) + $profileArg + $excludes

& aws @args
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Write-Host "Done. Check: https://$bucket.website.yandexcloud.net" -ForegroundColor Green
