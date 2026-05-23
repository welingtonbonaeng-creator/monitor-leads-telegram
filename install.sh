#!/usr/bin/env bash
# ================================================================
# Instalador da Skill /monitor-leads-telegram
# Monitor de Leads Meta Ads → Telegram (24/7 via GitHub Actions)
# ================================================================
# Como usar:
#   chmod +x install.sh && ./install.sh
# ================================================================

set -e

SKILL_NAME="monitor-leads-telegram"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "================================================================"
echo "  Instalador — /monitor-leads-telegram"
echo "  Monitor de Leads Meta Ads → Telegram (24/7)"
echo "================================================================"
echo ""

# 1. Verificar Claude Code
if ! command -v claude &> /dev/null; then
    echo "⚠️  Claude Code não encontrado no PATH."
    echo "   Certifique-se de que o Claude Code está instalado."
    echo "   Download: https://claude.ai/code"
    echo ""
fi

# 2. Criar diretório da skill
echo "📁 Criando diretório da skill..."
mkdir -p "$SKILL_DIR"
echo "   ✅ $SKILL_DIR"

# 3. Copiar SKILL.md
SOURCE="$SCRIPT_DIR/SKILL.md"
DEST="$SKILL_DIR/SKILL.md"

if [ -f "$SOURCE" ]; then
    cp "$SOURCE" "$DEST"
    echo "   ✅ SKILL.md instalado"
else
    echo "❌ Arquivo SKILL.md não encontrado em: $SOURCE"
    echo "   Certifique-se de que install.sh e SKILL.md estão na mesma pasta."
    exit 1
fi

echo ""
echo "================================================================"
echo "  ✅ Skill instalada com sucesso!"
echo "================================================================"
echo ""
echo "  Próximo passo:"
echo "  1. Abra o Claude Code"
echo "  2. Digite: /monitor-leads-telegram"
echo "  3. Siga as instruções do agente (15–20 min)"
echo ""
echo "  O agente vai configurar TUDO automaticamente:"
echo "  ✓ Conectar na sua conta do Facebook"
echo "  ✓ Criar seu bot no Telegram"
echo "  ✓ Criar repositório na SUA conta do GitHub"
echo "  ✓ Fazer deploy do código"
echo "  ✓ Testar e verificar o primeiro run"
echo ""
