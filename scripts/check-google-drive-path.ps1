# Check if project path is inside Google Drive sync (including MYDISK mount)
# Run: .\scripts\check-google-drive-path.ps1

param(
  [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$path = $ProjectRoot
$hit = $null

$markers = @(
  'Google Drive',
  'GoogleDrive',
  'My Drive',
  'Drive File Stream',
  'CloudStorage'
)

foreach ($m in $markers) {
  if ($path -like "*$m*") {
    $hit = $m
    break
  }
}

# This PC: G:\My Drive.lnk often points to C:\Users\<user>\MYDISK
$mydisk = Join-Path $env:USERPROFILE 'MYDISK'
if (-not $hit -and $mydisk -and ($path -like "$mydisk*")) {
  $lnk = 'G:\My Drive.lnk'
  if (Test-Path $lnk) {
    try {
      $sh = New-Object -ComObject WScript.Shell
      $target = $sh.CreateShortcut($lnk).TargetPath
      if ($target -and ($mydisk -eq $target -or $path -like "$target*")) {
        $hit = 'MYDISK (Google Drive sync root)'
      }
    } catch {
      $hit = 'MYDISK (suspected Google Drive)'
    }
  }
}

Write-Host "Project: $path"

if ($hit) {
  Write-Host ""
  Write-Host "WARNING: project is inside Google Drive sync ($hit)." -ForegroundColor Yellow
  Write-Host "Use C:\Users\AM\Projects\Y\edecorus.ru in Cursor (see scripts\setup-local-workspace.ps1)." -ForegroundColor Green
  exit 1
}

Write-Host "OK: safe path for Cursor + git." -ForegroundColor Green
exit 0
