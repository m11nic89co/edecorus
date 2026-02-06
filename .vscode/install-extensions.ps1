# Оставшиеся расширения — запустите в терминале Cursor (Ctrl+`) если нужно доустановить
$c = "C:\Users\AM\AppData\Local\Programs\cursor\resources\app\bin\cursor.cmd"
@(
  "eamodio.gitlens",
  "christian-kohler.path-intellisense",
  "humao.rest-client",
  "streetsidesoftware.code-spell-checker",
  "streetsidesoftware.code-spell-checker-russian",
  "wix.vscode-import-cost",
  "jock.svg"
) | ForEach-Object { & $c --install-extension $_ }
