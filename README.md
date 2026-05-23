# 🤖 Skill: /monitor-leads-telegram
### Monitor de Leads Meta Ads → Telegram — 24/7 via GitHub Actions

Esta skill instala um agente que monitora automaticamente seus formulários de lead do Meta Ads e entrega cada novo lead direto no Telegram — com nome, telefone normalizado, link WhatsApp, email, objetivo e dica de abordagem.

**Roda nos servidores do GitHub a cada 5 minutos. PC ligado ou desligado.**

---

## O que você recebe no Telegram

```
🔔 Novo Lead!
━━━━━━━━━━━━━━━━━
🟢 ALTO  João Silva — 23/05 14:32
✅ WhatsApp: [Abrir conversa](https://wa.me/5521987654321)
📞 Ligar se necessário: +5521987654321
📧 Email: joao@email.com
━━━━━━━━━━━━━━━━━
🎯 Objetivo: Investimento / Valorização
📢 Campanha: Porto Maravilha | Leads
👥 Público: Offshore | Petróleo
━━━━━━━━━━━━━━━━━
💡 Abordagem: Perfil investidor. Apresentar ROI e histórico
   de valorização da região. Perguntar capital disponível.
```

---

## Instalação (1 minuto)

### Pré-requisito: Claude Code
Você precisa do [Claude Code](https://claude.ai/code) instalado.

### Windows
```powershell
# Abra o PowerShell e execute:
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/welingtonbonaeng-creator/monitor-leads-telegram/main/install.ps1" -OutFile "$env:TEMP\install-skill.ps1"; & "$env:TEMP\install-skill.ps1"
```

### Mac / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/welingtonbonaeng-creator/monitor-leads-telegram/main/install.sh | bash
```

### Manual (qualquer sistema)
1. Crie a pasta `~/.claude/skills/monitor-leads-telegram/`
2. Copie o arquivo `SKILL.md` para dentro dessa pasta
3. Abra o Claude Code
4. Digite `/monitor-leads-telegram` e siga as instruções

---

## Como usar

Depois de instalar, abra o Claude Code e digite:
```
/monitor-leads-telegram
```

O agente vai te guiar por **6 passos**:
1. 🔑 Token do Facebook (Graph API)
2. 📋 ID do seu formulário de lead
3. 📱 Criação do bot Telegram (ou usar um existente)
4. 💻 Token do GitHub
5. 🚀 Deploy automático do código
6. ✅ Primeiro teste e verificação

**Tempo total: ~15–20 minutos.**

---

## O que é criado automaticamente

- Repositório privado no seu GitHub
- Script Python com toda a lógica de monitoramento
- GitHub Actions workflow (cron a cada 5 min)
- Secrets configurados com suas credenciais
- Primeiro run testado e verificado

---

## Requisitos

| Conta | Nível | Notas |
|-------|-------|-------|
| Meta Ads | Ativo | Com formulários de lead configurados |
| Facebook Developer | Gratuito | Para gerar o token de acesso |
| Telegram | Gratuito | Para criar o bot via @BotFather |
| GitHub | Gratuito | Conta pessoal (repositório privado) |

---

## Personalização

O script suporta os seguintes campos de formulário Meta Ads:

| Campo | Descrição |
|-------|-----------|
| `full_name` | Nome completo |
| `phone_number` | Telefone (normalizado automaticamente para E.164) |
| `email` | Email |
| `objetivo_imovel` | Objetivo: `proprio` / `valorizacao` / `airbnb` |

Se seus formulários usam outros nomes de campos ou outros objetivos, o agente adapta o script durante o setup.

---

## Suporte

- Criado por [@orientador.welington](https://instagram.com/orientador.welington)
- Sistema Jesus — Discípulo MATIAS (13º)
