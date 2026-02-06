# Скрипт клонирования репозитория edecorus
# https://github.com/m11nic89co/edecorus

$repoUrl = "https://github.com/m11nic89co/edecorus"
$zipUrl = "https://github.com/m11nic89co/edecorus/archive/refs/heads/main.zip"
$targetDir = $PSScriptRoot

Write-Host "=== Клонирование репозитория edecorus ===" -ForegroundColor Cyan

# Попытка 1: Git clone
$gitPaths = @(
    "git",
    "C:\Program Files\Git\bin\git.exe",
    "C:\Program Files (x86)\Git\bin\git.exe"
)

foreach ($git in $gitPaths) {
    try {
        $null = & $git --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Найден Git: $git" -ForegroundColor Green
            Set-Location $targetDir
            if (Get-ChildItem -Force | Where-Object { $_.Name -ne "clone.ps1" -and $_.Name -ne "README.md" }) {
                Write-Host "Папка не пуста. Клонируем во временную папку..." -ForegroundColor Yellow
                $tempDir = Join-Path $targetDir "edecorus-temp"
                & $git clone $repoUrl $tempDir
                if ($LASTEXITCODE -eq 0) {
                    Get-ChildItem $tempDir | Move-Item -Destination $targetDir -Force
                    Remove-Item $tempDir -Force
                    Write-Host "Репозиторий успешно склонирован!" -ForegroundColor Green
                    exit 0
                }
            } else {
                & $git clone $repoUrl .
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "Репозиторий успешно склонирован!" -ForegroundColor Green
                    exit 0
                }
            }
            break
        }
    } catch {
        continue
    }
}

# Попытка 2: Скачивание ZIP
Write-Host "Git не найден. Пробуем скачать ZIP..." -ForegroundColor Yellow
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $zipPath = Join-Path $targetDir "edecorus-main.zip"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $targetDir -Force
    $extractedDir = Join-Path $targetDir "edecorus-main"
    Get-ChildItem $extractedDir | Move-Item -Destination $targetDir -Force
    Remove-Item $extractedDir -Force
    Remove-Item $zipPath -Force
    Write-Host "Репозиторий успешно загружен из ZIP!" -ForegroundColor Green
    exit 0
} catch {
    Write-Host "Ошибка загрузки: $_" -ForegroundColor Red
}

# Инструкции для ручной загрузки
Write-Host "`n=== Ручная загрузка ===" -ForegroundColor Yellow
Write-Host "1. Установите Git: winget install Git.Git" -ForegroundColor White
Write-Host "2. Или скачайте ZIP в браузере: $zipUrl" -ForegroundColor White
Write-Host "3. Распакуйте архив и скопируйте содержимое папки edecorus-main сюда" -ForegroundColor White
