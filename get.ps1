# Instalador da Skill /monitor-leads-telegram
$dir = "$env:USERPROFILE\.claude\skills\monitor-leads-telegram"
New-Item -ItemType Directory -Force $dir | Out-Null
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/welingtonbonaeng-creator/monitor-leads-telegram/main/SKILL.md" -OutFile "$dir\SKILL.md" -UseBasicParsing
Write-Host ""
Write-Host "Skill instalada com sucesso!" -ForegroundColor Green
Write-Host "Abra o Claude Code e digite: /monitor-leads-telegram" -ForegroundColor Cyan
