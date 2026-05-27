# Load keys from yc-keys.local.env, configure AWS profile yc, deploy site.
$ErrorActionPreference = 'Stop'
$keysFile = Join-Path $PSScriptRoot 'yc-keys.local.env'

if (-not (Test-Path $keysFile)) {
  Write-Host "Create $keysFile from yc-keys.local.env.example and paste keys." -ForegroundColor Red
  exit 1
}

Get-Content $keysFile | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }
  if ($_ -match '^\s*([^=]+)=(.*)$') {
    $name = $Matches[1].Trim()
    $value = $Matches[2].Trim().Trim('"').Trim("'")
    if ($value -match '^(YCAJ|YCOx|PASTE)') { return }
    Set-Item -Path "env:$name" -Value $value
  }
}

if (-not $env:AWS_ACCESS_KEY_ID -or -not $env:AWS_SECRET_ACCESS_KEY) {
  Write-Host 'Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in yc-keys.local.env' -ForegroundColor Red
  exit 1
}

$awsDir = Join-Path $env:USERPROFILE '.aws'
$null = New-Item -ItemType Directory -Force -Path $awsDir
$credPath = Join-Path $awsDir 'credentials'
$block = @"
[yc]
aws_access_key_id = $($env:AWS_ACCESS_KEY_ID)
aws_secret_access_key = $($env:AWS_SECRET_ACCESS_KEY)
"@

if (Test-Path $credPath) {
  $content = Get-Content $credPath -Raw
  if ($content -match '\[yc\]') {
    $content = $content -replace '(?ms)\[yc\][^\[]*', ''
  }
  Set-Content -Path $credPath -Value ($content.TrimEnd() + "`n`n" + $block) -Encoding utf8
} else {
  Set-Content -Path $credPath -Value $block -Encoding utf8
}

Write-Host 'AWS profile [yc] configured.' -ForegroundColor Green

if (Get-Command gh -ErrorAction SilentlyContinue) {
  $env:YC_SA_ACCESS_KEY_ID = $env:AWS_ACCESS_KEY_ID
  $env:YC_SA_SECRET_ACCESS_KEY = $env:AWS_SECRET_ACCESS_KEY
  gh secret set YC_SA_ACCESS_KEY_ID --body $env:AWS_ACCESS_KEY_ID 2>$null
  gh secret set YC_SA_SECRET_ACCESS_KEY --body $env:AWS_SECRET_ACCESS_KEY 2>$null
  Write-Host 'GitHub secrets updated (if repo access allows).' -ForegroundColor Cyan
}

$pyDeploy = Join-Path $PSScriptRoot 'deploy-yandex-boto3.py'
if (Test-Path $pyDeploy) {
  python $pyDeploy
} else {
  & (Join-Path $PSScriptRoot 'deploy-yandex-s3.ps1')
}
