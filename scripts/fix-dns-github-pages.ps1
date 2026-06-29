# DNS: переключение edecorus.ru на GitHub Pages
# Запускать после входа в Cloudflare (нужен API Token с правом Zone.DNS Edit)

param(
  [Parameter(Mandatory = $true)]
  [string]$CloudflareApiToken,
  [string]$ZoneName = 'edecorus.ru'
)

$ErrorActionPreference = 'Stop'
$headers = @{
  Authorization = "Bearer $CloudflareApiToken"
  'Content-Type' = 'application/json'
}

$zone = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones?name=$ZoneName" -Headers $headers
$zoneId = $zone.result[0].id
if (-not $zoneId) { throw "Zone not found: $ZoneName" }

$githubA = @('185.199.108.153', '185.199.109.153', '185.199.110.153', '185.199.111.153')

$records = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records?per_page=100" -Headers $headers

foreach ($rec in $records.result) {
  if ($rec.name -eq $ZoneName -and $rec.type -eq 'A' -and $rec.content -eq '213.180.193.247') {
    Invoke-RestMethod -Method Delete -Uri "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$($rec.id)" -Headers $headers | Out-Null
    Write-Host "Deleted old A record -> $($rec.content)" -ForegroundColor Yellow
  }
}

foreach ($ip in $githubA) {
  $body = @{
    type = 'A'
    name = '@'
    content = $ip
    ttl = 300
    proxied = $false
  } | ConvertTo-Json
  Invoke-RestMethod -Method Post -Uri "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records" -Headers $headers -Body $body | Out-Null
  Write-Host "Added A @ -> $ip" -ForegroundColor Green
}

$wwwBody = @{
  type = 'CNAME'
  name = 'www'
  content = 'm11nic89co.github.io'
  ttl = 300
  proxied = $false
} | ConvertTo-Json

$www = $records.result | Where-Object { $_.name -eq "www.$ZoneName" -and $_.type -eq 'CNAME' }
if ($www) {
  Invoke-RestMethod -Method Put -Uri "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$($www.id)" -Headers $headers -Body $wwwBody | Out-Null
} else {
  Invoke-RestMethod -Method Post -Uri "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records" -Headers $headers -Body $wwwBody | Out-Null
}
Write-Host "Updated www CNAME -> m11nic89co.github.io" -ForegroundColor Green
Write-Host "Wait 5-15 min, then open https://edecorus.ru/" -ForegroundColor Cyan
