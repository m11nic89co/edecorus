# One-way copy: local repo -> Google Drive (backup/archive). Not a live dev folder.
# 1) Copy workspace-paths.example.ps1 to workspace-paths.local.ps1
# 2) Set $GoogleDriveRoot
# 3) .\scripts\sync-to-google-drive.ps1

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$localConfig = Join-Path $PSScriptRoot 'workspace-paths.local.ps1'

if (-not (Test-Path $localConfig)) {
  Write-Host "Create workspace-paths.local.ps1 from workspace-paths.example.ps1" -ForegroundColor Red
  exit 1
}

. $localConfig

if (-not $GoogleDriveRoot) {
  Write-Host 'Set $GoogleDriveRoot in workspace-paths.local.ps1' -ForegroundColor Red
  exit 1
}

$destSite = Join-Path $GoogleDriveRoot 'site'
$destDocs = Join-Path $GoogleDriveRoot 'docs'

New-Item -ItemType Directory -Force -Path $destSite, $destDocs | Out-Null

$exclude = @('.git', 'scripts', 'drive-archive', '.vscode', '.cursor')

Write-Host "Copying site to: $destSite"
Get-ChildItem -Path $repoRoot -Force | Where-Object {
  $exclude -notcontains $_.Name
} | ForEach-Object {
  Copy-Item -Path $_.FullName -Destination $destSite -Recurse -Force
}

$archiveDir = Join-Path $repoRoot 'drive-archive'
if (Test-Path $archiveDir) {
  Write-Host "Copying drive-archive to: $destDocs"
  Copy-Item -Path (Join-Path $archiveDir '*') -Destination $destDocs -Recurse -Force
}

Write-Host "Done. Drive folders: site/, docs/" -ForegroundColor Green
