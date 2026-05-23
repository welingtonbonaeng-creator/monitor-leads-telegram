# ================================================================
# Instalador da Skill /monitor-leads-telegram
# Monitor de Leads Meta Ads → Telegram (24/7 via GitHub Actions)
# ================================================================
# Como usar:
#   1. Salve este arquivo em qualquer pasta
#   2. Abra o PowerShell e execute: .\install.ps1
#   3. Abra o Claude Code e digite: /monitor-leads-telegram
# ================================================================

$ErrorActionPreference = "Stop"
$SKILL_NAME = "monitor-leads-telegram"
$SKILL_DIR  = "$env:USERPROFILE\.claude\skills\$SKILL_NAME"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Instalador — /monitor-leads-telegram" -ForegroundColor Cyan
Write-Host "  Monitor de Leads Meta Ads → Telegram (24/7)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar Claude Code
$claudePath = Get-Command "claude" -ErrorAction SilentlyContinue
if (-not $claudePath) {
    Write-Host "⚠️  Claude Code não encontrado no PATH." -ForegroundColor Yellow
    Write-Host "   Certifique-se de que o Claude Code está instalado." -ForegroundColor Yellow
    Write-Host "   Download: https://claude.ai/code" -ForegroundColor Yellow
    Write-Host ""
}

# 2. Criar diretório da skill
Write-Host "📁 Criando diretório da skill..." -ForegroundColor White
New-Item -ItemType Directory -Force -Path $SKILL_DIR | Out-Null
Write-Host "   ✅ $SKILL_DIR" -ForegroundColor Green

# 3. Copiar SKILL.md para o diretório correto
$SOURCE = Join-Path $PSScriptRoot "SKILL.md"
$DEST   = Join-Path $SKILL_DIR "SKILL.md"

if (Test-Path $SOURCE) {
    Copy-Item -Path $SOURCE -Destination $DEST -Force
    Write-Host "   ✅ SKILL.md instalado" -ForegroundColor Green
} else {
    Write-Host "❌ Arquivo SKILL.md não encontrado em: $SOURCE" -ForegroundColor Red
    Write-Host "   Certifique-se de que install.ps1 e SKILL.md estão na mesma pasta." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  ✅ Skill instalada com sucesso!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Próximo passo:" -ForegroundColor White
Write-Host "  1. Abra o Claude Code" -ForegroundColor White
Write-Host "  2. Digite: /monitor-leads-telegram" -ForegroundColor Cyan
Write-Host "  3. Siga as instruções do agente (15–20 min)" -ForegroundColor White
Write-Host ""
Write-Host "  O agente vai configurar TUDO automaticamente:" -ForegroundColor White
Write-Host "  ✓ Conectar na sua conta do Facebook" -ForegroundColor Gray
Write-Host "  ✓ Criar seu bot no Telegram" -ForegroundColor Gray
Write-Host "  ✓ Criar repositório na SUA conta do GitHub" -ForegroundColor Gray
Write-Host "  ✓ Fazer deploy do código" -ForegroundColor Gray
Write-Host "  ✓ Testar e verificar o primeiro run" -ForegroundColor Gray
Write-Host ""
