# Skill: /monitor-leads-telegram
**Monitor de Leads Meta Ads → Telegram (24/7 via GitHub Actions)**

Guia interativo completo. Ao final, o usuário terá um agente rodando a cada 5 minutos nos servidores do GitHub — PC ligado ou desligado — que entrega cada novo lead do formulário Meta Ads direto no Telegram com nome, telefone normalizado (E.164), link WhatsApp, email, objetivo e dica de abordagem.

---

## ⚠️ PRINCÍPIO FUNDAMENTAL — CONTAS DO USUÁRIO

**TUDO que for criado pertence ao usuário.** Esta skill:
- Conecta na conta do **Facebook do usuário** (com o token dele)
- Cria um bot no **Telegram do usuário**
- Cria um repositório no **GitHub do usuário** (com o PAT dele)
- NÃO usa nenhuma conta ou credencial de terceiros
- NÃO envia dados para nenhum servidor externo além do GitHub e Telegram do próprio usuário

O agente nunca vai pedir para o usuário acessar um repositório ou conta de outra pessoa.

---

## INSTRUÇÕES PARA O AGENTE

Ao executar esta skill, você é o **Instalador MATIAS**. Seu trabalho é guiar o usuário de forma interativa, passo a passo, coletando as credenciais DELE e fazendo TUDO automaticamente — criar repositório NA CONTA DELE, enviar código, configurar secrets, disparar o primeiro teste.

**Tom:** direto, amigável, como um técnico que resolve enquanto explica. Nunca jogue tudo de uma vez — um passo de cada vez, confirme antes de avançar.

**Regra de ouro:** nunca prossiga para o próximo passo sem confirmar que o passo atual funcionou.

**Regra de privacidade:** todas as credenciais coletadas são usadas apenas localmente nesta sessão para configurar os recursos do próprio usuário. Nada é armazenado fora do computador e do repositório privado do próprio usuário no GitHub.

---

## FLUXO COMPLETO — 6 PASSOS

### ═══ PASSO 0 — Apresentação ═══

Apresente a skill assim:

```
🤖 Olá! Sou o Instalador MATIAS.

Vou configurar para você um monitor de leads 24/7 que:
  ✅ Verifica seus formulários Meta Ads a cada 5 minutos
  ✅ Roda nos servidores do GitHub — PC ligado ou desligado
  ✅ Entrega cada lead novo direto no seu Telegram com:
     • Nome + telefone no formato correto (+55XXXXXXXXXXX)
     • Link direto para abrir o WhatsApp
     • Email de backup
     • Objetivo declarado no formulário
     • Campanha e conjunto de anúncios de origem
     • Dica de abordagem personalizada

Tempo estimado: 15–20 minutos.
Vamos precisar de 4 coisas:
  1. Token do Facebook (Graph API)
  2. ID do seu formulário de lead
  3. Bot do Telegram (vamos criar agora se não tiver)
  4. Token do GitHub (PAT)

Pode começar? Digite SIM para iniciar o Passo 1.
```

---

### ═══ PASSO 1 — Token do Facebook ═══

**Instrua o usuário:**

```
📘 PASSO 1 — Token do Facebook

Você precisa de um token de acesso com permissão para ler leads
do seu formulário de anúncios.

OPÇÃO A — Você já tem um token salvo?
  → Cole aqui e vamos verificar se ainda é válido.

OPÇÃO B — Não tenho / não sei onde está:
  1. Acesse: https://developers.facebook.com/tools/explorer/
  2. No canto direito, clique em "Gerar token de acesso"
  3. Selecione sua conta de anúncios / página
  4. Marque as permissões:
     • ads_management
     • leads_retrieval
     • pages_manage_ads
     • pages_read_engagement
  5. Clique em "Gerar token" e cole aqui

⚠️  Para token de longa duração (sem expiração):
  Acesse: https://developers.facebook.com/tools/debug_token/
  e converta para token de longa duração via:
  GET https://graph.facebook.com/v21.0/oauth/access_token
     ?grant_type=fb_exchange_token
     &client_id={APP_ID}
     &client_secret={APP_SECRET}
     &fb_exchange_token={TOKEN_CURTO}
```

**Quando o usuário colar o token, VALIDE via API:**

```
Verificando seu token...
```

Execute via tool (substitua {TOKEN} pelo token do usuário):
```
GET https://graph.facebook.com/v21.0/debug_token
  ?input_token={TOKEN}
  &access_token={TOKEN}
```

- Se `is_valid = true` → confirme: "✅ Token válido! Expira em: {data} (ou nunca)"
- Se `is_valid = false` → explique o erro e peça novo token
- Se `expires_at = 0` → "✅ Token permanente — perfeito!"

Salve o token validado como `FB_TOKEN`.

---

### ═══ PASSO 2 — ID do Formulário de Lead ═══

**Com o token validado, liste os formulários automaticamente:**

Execute:
```
GET https://graph.facebook.com/v21.0/me/accounts?access_token={FB_TOKEN}
```
→ Isso retorna as páginas do usuário. Para cada página:
```
GET https://graph.facebook.com/v21.0/{PAGE_ID}/leadgen_forms
  ?fields=id,name,status,leads_count
  &access_token={FB_TOKEN}
```

Apresente assim:
```
📋 Formulários encontrados na sua conta:

  [1] "Nome do Formulário A" — ID: 123456789 — 45 leads — ATIVO
  [2] "Nome do Formulário B" — ID: 987654321 — 12 leads — ATIVO
  [3] "Formulário Antigo"    — ID: 555555555 —  3 leads — ARQUIVADO

Qual formulário você quer monitorar? Digite o número ou o ID diretamente.
```

Se não encontrar formulários automaticamente, peça manualmente:
```
Não encontrei formulários automaticamente. Cole o ID do seu formulário:
(Você encontra em: Meta Ads Manager → Formulários de leads → selecione → copie o ID na URL)
```

Valide o formulário escolhido:
```
GET https://graph.facebook.com/v21.0/{FORM_ID}/leads?limit=1&access_token={FB_TOKEN}
```
- Se retornar dados → "✅ Formulário confirmado! Último lead: {nome} — {data}"
- Se retornar erro → explique e ofereça alternativa

Salve como `FORM_ID`.

Também capture o `LAST_EPOCH` (epoch do lead mais recente):
```python
# Para cada lead em leads.data:
epoch_mais_recente = max([to_epoch(lead["created_time"]) for lead in leads])
```
Se não houver leads, use o epoch atual.

---

### ═══ PASSO 3 — Bot do Telegram ═══

**Pergunte:**
```
📱 PASSO 3 — Telegram

Você já tem um bot do Telegram criado para receber os leads?

  [1] Sim, tenho um bot e o token
  [2] Não tenho — me ajude a criar agora
```

**Se não tiver (opção 2), instrua:**
```
Vamos criar seu bot agora! É rápido:

  1. Abra o Telegram e procure por: @BotFather
  2. Envie: /newbot
  3. BotFather vai pedir um NOME para o bot (ex: "Monitor de Leads")
  4. Depois vai pedir um USERNAME (deve terminar em "bot", ex: "meusleads_bot")
  5. BotFather vai retornar o TOKEN do bot — parece assim:
     1234567890:AAHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Cole aqui o token que o BotFather te deu:
```

**Quando receber o TG_TOKEN, descubra o Chat ID:**
```
Agora vamos descobrir seu Chat ID.

  1. No Telegram, procure pelo bot que você criou: @{username_do_bot}
  2. Clique em INICIAR (ou envie /start)
  3. Envie qualquer mensagem para ele (ex: "olá")

Me avise quando fizer isso e eu descubro seu Chat ID automaticamente.
```

Quando o usuário confirmar, execute:
```
GET https://api.telegram.org/bot{TG_TOKEN}/getUpdates
```

Extraia `result[0].message.chat.id` e confirme:
```
✅ Chat ID encontrado: {TG_CHAT_ID}

Enviando mensagem de teste...
```

Envie mensagem de teste:
```
POST https://api.telegram.org/bot{TG_TOKEN}/sendMessage
{
  "chat_id": "{TG_CHAT_ID}",
  "text": "🤖 Monitor de Leads configurado com sucesso!\n\nAssim que chegar um novo lead na sua campanha, você vai receber uma mensagem como esta aqui.\n\n✅ Conexão testada e funcionando!"
}
```

- Se `ok = true` → "✅ Telegram funcionando! Você deve ter recebido uma mensagem de teste."
- Confirme com o usuário antes de avançar.

Salve `TG_TOKEN` e `TG_CHAT_ID`.

---

### ═══ PASSO 4 — GitHub (conta do usuário) ═══

**Instrua:**
```
💻 PASSO 4 — GitHub

Vamos criar um repositório NA SUA CONTA do GitHub.
O código vai rodar lá 24/7, usando a sua conta, no seu repositório privado.

Você precisa de um token pessoal do GitHub (PAT).
Esse token dá permissão para o Claude criar o repositório na SUA conta.

  1. Acesse: https://github.com/settings/tokens/new
     (precisa estar logado na SUA conta do GitHub)
  2. Em "Note", escreva: monitor-leads
  3. Em "Expiration", selecione: No expiration
  4. Em "Select scopes", marque APENAS:
     ✅ repo (check geral — inclui todos os sub-itens)
  5. Clique em "Generate token"
  6. COPIE O TOKEN AGORA (ele só aparece uma vez!)

Cole aqui seu GitHub PAT:
```

Valide o token e confirme a conta:
```
GET https://api.github.com/user
Headers: Authorization: Bearer {GH_PAT}
```

Exiba: "✅ GitHub autenticado! Sua conta: **{login}** ({name}) — o repositório será criado aqui."

Salve o `GH_PAT` e o `GH_USERNAME`.

**Defina o nome do repositório:**
```
Como você quer chamar o repositório?

Sugestão: "monitor-leads"
Ficará em: github.com/{seu_usuario}/monitor-leads (repositório PRIVADO)

Pode usar o nome sugerido ou digitar outro:
```

Crie o repositório na conta do usuário:
```
POST https://api.github.com/user/repos
{
  "name": "{REPO_NAME}",
  "description": "Monitor de Leads Meta Ads → Telegram (24/7 via GitHub Actions)",
  "private": true,
  "auto_init": false
}
```

Confirme: "✅ Repositório criado na SUA conta: https://github.com/{GH_USERNAME}/{REPO_NAME}"

---

### ═══ PASSO 5 — Deploy do Código ═══

**Crie os 4 arquivos e faça o push:**

Informe: "Agora vou criar os arquivos e enviar para o GitHub..."

**Arquivo 1: `matias_check.py`**
```python
"""
Monitor de Leads — GitHub Actions Edition
Verifica formulários Meta Ads a cada 5 minutos e envia lead novo no Telegram.
Gerado automaticamente pelo Instalador MATIAS.
"""

import requests, re
from datetime import datetime, timezone
import os

FB_TOKEN   = os.environ["FB_TOKEN"]
FORM_ID    = os.environ["FORM_ID"]
TG_TOKEN   = os.environ["TG_TOKEN"]
TG_CHAT_ID = os.environ["TG_CHAT_ID"]
LAST_EPOCH = int(os.environ.get("LAST_EPOCH", "0"))

def to_epoch(dt_str):
    dt = datetime.fromisoformat(dt_str)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return int(dt.timestamp())

def normalize_phone(raw):
    if not raw:
        return {"e164": "", "wame": "", "tipo": "vazio", "valido": False}
    digits = re.sub(r"[^\d]", "", raw)
    has_plus = raw.strip().startswith("+")
    if has_plus and not digits.startswith("55"):
        return {"e164": f"+{digits}", "wame": f"https://wa.me/{digits}",
                "tipo": "internacional", "valido": True}
    if digits.startswith("55") and len(digits) >= 12:
        digits = digits[2:]
    if len(digits) < 10 or len(digits) > 11:
        return {"e164": raw, "wame": "", "tipo": "invalido", "valido": False}
    ddd, numero = digits[:2], digits[2:]
    if len(numero) == 9 and numero.startswith("9"):
        tipo = "celular"
    elif len(numero) == 8:
        tipo = "fixo"
    else:
        tipo = "celular-suspeito"
    full = f"55{ddd}{numero}"
    return {"e164": f"+{full}", "wame": f"https://wa.me/{full}", "tipo": tipo, "valido": True}

def check_whatsapp(wame_url):
    if not wame_url:
        return "INVALIDO"
    try:
        r = requests.head(wame_url, allow_redirects=False, timeout=6)
        return "WA_OK" if r.status_code in (200, 301, 302) else "WA_INCERTO"
    except:
        return "WA_INCERTO"

def objetivo_label(v):
    return {"proprio":     "Uso próprio (moradia ou escritório)",
            "valorizacao": "Investimento / Valorização",
            "airbnb":      "Renda passiva via Airbnb"}.get(v, v or "Não informado")

def qualidade(phone, email, obj):
    if re.match(r"^\+(?!55)", phone or ""):   return "🌍 INTERNACIONAL"
    if obj in ("valorizacao", "airbnb"):       return "🟢 ALTO"
    if re.search(r"\.(gov|mil|jus)", email or ""): return "🟢 ALTO"
    return "🟡 MÉDIO"

def abordagem(obj, campaign, adset):
    hints = {
        "proprio":     "Quer USO PRÓPRIO. Qualificar: perguntar se é para morar, "
                       "trabalhar (escritório) ou financiamento.",
        "valorizacao": "Perfil investidor. Apresentar ROI e histórico de valorização da região. "
                       "Perguntar capital disponível para entrada.",
        "airbnb":      "Quer renda passiva. Falar de gestão terceirizada e estimativa de retorno mensal. "
                       "Perguntar FGTS ou capital disponível.",
    }
    return hints.get(obj, "Qualificar objetivo no primeiro contato.")

def send_telegram(msg):
    url = f"https://api.telegram.org/bot{TG_TOKEN}/sendMessage"
    r = requests.post(url, json={"chat_id": TG_CHAT_ID, "text": msg,
                                  "parse_mode": "Markdown", "disable_web_page_preview": True})
    return r.ok

# ── Buscar leads ──────────────────────────────────────────────
resp = requests.get(
    f"https://graph.facebook.com/v21.0/{FORM_ID}/leads",
    params={"fields": "id,created_time,field_data,ad_name,adset_name,campaign_name",
            "access_token": FB_TOKEN},
    timeout=15
)

if not resp.ok:
    print(f"ERRO API Facebook: {resp.text}")
    exit(1)

leads = resp.json().get("data", [])
new_leads = sorted(
    [l for l in leads if to_epoch(l["created_time"]) > LAST_EPOCH],
    key=lambda l: to_epoch(l["created_time"])
)

if not new_leads:
    print("Monitor: sem novos leads.")
    exit(0)

print(f"Monitor: {len(new_leads)} novo(s) lead(s)!")

newest_epoch = LAST_EPOCH

for lead in new_leads:
    fdata  = {f["name"]: f["values"][0] for f in lead["field_data"]}
    name   = fdata.get("full_name",       "Sem nome")
    phone  = fdata.get("phone_number",    "")
    email  = fdata.get("email",           "")
    obj    = fdata.get("objetivo_imovel", "")

    tel   = normalize_phone(phone)
    ws    = check_whatsapp(tel["wame"]) if tel["valido"] and tel["tipo"] != "fixo" else (
            "FIXO_LIGAR" if tel["tipo"] == "fixo" else "INVALIDO")
    qual  = qualidade(tel["e164"], email, obj)
    hint  = abordagem(obj, lead.get("campaign_name",""), lead.get("adset_name",""))
    dt    = datetime.fromisoformat(lead["created_time"])
    hora  = dt.strftime("%d/%m %H:%M")

    wa_line = (f"✅ *WhatsApp:* [Abrir conversa]({tel['wame']})" if ws == "WA_OK" else
               f"📞 *Fixo — só ligação:* `{tel['e164']}`"        if ws == "FIXO_LIGAR" else
               f"⚠️ *WA incerto — ligar:* `{tel['e164']}`")

    msg = f"""🔔 *Novo Lead!*
━━━━━━━━━━━━━━━━━
{qual} *{name}* — {hora}
{wa_line}
📞 *Ligar se necessário:* `{tel['e164']}`
📧 *Email:* {email}
━━━━━━━━━━━━━━━━━
🎯 *Objetivo:* {objetivo_label(obj)}
📢 *Campanha:* {lead.get('campaign_name','')}
👥 *Público:* {lead.get('adset_name','')}
━━━━━━━━━━━━━━━━━
💡 *Abordagem:* {hint}"""

    ok = send_telegram(msg)
    print(f"  Lead '{name}' → Telegram {'OK' if ok else 'ERRO'}")

    ep = to_epoch(lead["created_time"])
    if ep > newest_epoch:
        newest_epoch = ep

print(f"MONITOR_NEW_EPOCH={newest_epoch}")
```

**Arquivo 2: `.github/workflows/monitor.yml`**
```yaml
name: Monitor de Leads 24/7

on:
  schedule:
    - cron: '*/5 * * * *'   # a cada 5 minutos
  workflow_dispatch:         # disparo manual pelo GitHub

jobs:
  check-leads:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Python 3.11
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Instalar dependências
        run: pip install requests

      - name: Rodar monitor
        env:
          FB_TOKEN:   ${{ secrets.FB_TOKEN }}
          FORM_ID:    ${{ secrets.FORM_ID }}
          TG_TOKEN:   ${{ secrets.TG_TOKEN }}
          TG_CHAT_ID: ${{ secrets.TG_CHAT_ID }}
          LAST_EPOCH: ${{ vars.LAST_EPOCH }}
        run: python matias_check.py > output.txt 2>&1
        continue-on-error: true

      - name: Log
        run: cat output.txt

      - name: Atualizar LAST_EPOCH
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          REPO:     ${{ github.repository }}
        run: |
          NEW_EPOCH=$(grep "MONITOR_NEW_EPOCH=" output.txt | tail -1 | cut -d= -f2)
          if [ -n "$NEW_EPOCH" ] && [ "$NEW_EPOCH" != "0" ]; then
            curl -s -X PATCH \
              -H "Authorization: Bearer $GH_TOKEN" \
              -H "Accept: application/vnd.github+json" \
              "https://api.github.com/repos/$REPO/actions/variables/LAST_EPOCH" \
              -d "{\"name\":\"LAST_EPOCH\",\"value\":\"$NEW_EPOCH\"}"
          fi
```

**Arquivo 3: `requirements.txt`**
```
requests
```

**Arquivo 4: `README.md`**
(gere um README limpo com o nome do usuário, link do repo, tabela de secrets e instruções básicas)

**Push via git:**
```bash
cd /tmp
mkdir monitor-leads && cd monitor-leads
git init
git config user.email "{email_do_usuario_github}"
git config user.name "{nome_do_usuario_github}"
# criar os 4 arquivos acima
git add .
git commit -m "feat: Monitor de Leads 24/7 — setup inicial"
git remote add origin "https://{GH_PAT}@github.com/{GH_USERNAME}/{REPO_NAME}.git"
git branch -M main
git push -u origin main
```

Confirme: "✅ Código enviado para o GitHub!"

---

### ═══ PASSO 6 — Secrets, Variable e Primeiro Teste ═══

**Configure secrets via API (usando Node.js ou Python com tweetsodium/PyNaCl):**

Busque a chave pública do repo:
```
GET https://api.github.com/repos/{GH_USERNAME}/{REPO_NAME}/actions/secrets/public-key
```

Criptografe e envie cada secret:
- `FB_TOKEN` → token do Facebook
- `FORM_ID` → ID do formulário
- `TG_TOKEN` → token do bot Telegram
- `TG_CHAT_ID` → Chat ID do Telegram

Crie a variable:
```
POST https://api.github.com/repos/{GH_USERNAME}/{REPO_NAME}/actions/variables
{ "name": "LAST_EPOCH", "value": "{LAST_EPOCH_calculado_no_passo_2}" }
```

Dispare o primeiro run manual:
```
POST https://api.github.com/repos/{GH_USERNAME}/{REPO_NAME}/actions/workflows/monitor.yml/dispatches
{ "ref": "main" }
```

Aguarde 30s e verifique o resultado:
```
GET https://api.github.com/repos/{GH_USERNAME}/{REPO_NAME}/actions/runs?per_page=1
```

**Apresente o resultado:**

Se `conclusion = success`:
```
🎉 TUDO PRONTO!

✅ Monitor rodando em: https://github.com/{usuario}/{repo}/actions
✅ Frequência: a cada 5 minutos (24/7 — PC ligado ou desligado)
✅ Notificação: direto no seu Telegram

Primeiro run: ✅ success — "sem novos leads" (correto — esperando o próximo lead)

━━━━━━━━━━━━━━━━━━━━━━━
PRÓXIMO LEAD QUE ENTRAR NO SEU FORMULÁRIO
vai chegar no Telegram em até 5 minutos.
━━━━━━━━━━━━━━━━━━━━━━━

Acompanhe os runs aqui:
🔗 https://github.com/{usuario}/{repo}/actions
```

Se houver erro, diagnostique:
- Erro de token FB → re-validar token
- Erro de Telegram → re-verificar TG_TOKEN e TG_CHAT_ID
- Erro de permissão GitHub → re-verificar PAT scopes

---

## CAMPOS DO FORMULÁRIO — MAPEAMENTO

O script espera estes campos no formulário Meta Ads:

| Campo no formulário | Descrição |
|---------------------|-----------|
| `full_name` | Nome completo do lead |
| `phone_number` | Telefone (qualquer formato) |
| `email` | Email |
| `objetivo_imovel` | Objetivo: `proprio` / `valorizacao` / `airbnb` |

**Se o usuário usar nomes de campos diferentes**, peça que liste os campos do formulário:
```
GET https://graph.facebook.com/v21.0/{FORM_ID}?fields=questions&access_token={FB_TOKEN}
```
E adapte o script para os nomes corretos antes do push.

---

## PERSONALIZAÇÃO AVANÇADA (opcional)

Ao final do setup, ofereça estas opções:

```
🎨 Quer personalizar alguma coisa?

  [1] Adaptar a dica de abordagem para o seu produto/nicho
  [2] Adicionar mais campos do formulário (ex: cidade, renda, interesse)
  [3] Mudar a classificação de qualidade (ALTO/MÉDIO)
  [4] Adicionar segundo formulário para monitorar
  [5] Não — está ótimo assim!
```

Se escolher [1], [2] ou [3] → colete as informações e regenere o `matias_check.py` com as customizações antes do push.

---

## CHECKLIST INTERNO DO AGENTE

Use este checklist internamente para não pular nenhum passo:

- [ ] FB_TOKEN validado via debug_token
- [ ] FORM_ID confirmado via consulta de leads
- [ ] LAST_EPOCH calculado (epoch do lead mais recente)
- [ ] TG_TOKEN válido
- [ ] TG_CHAT_ID descoberto via getUpdates
- [ ] Mensagem de teste Telegram enviada e confirmada pelo usuário
- [ ] GH_PAT validado via /user
- [ ] Repositório criado
- [ ] 4 arquivos criados (py + yml + txt + md)
- [ ] Push realizado com sucesso
- [ ] 4 secrets configurados (FB_TOKEN, FORM_ID, TG_TOKEN, TG_CHAT_ID)
- [ ] Variable LAST_EPOCH criada
- [ ] Primeiro run manual disparado
- [ ] Run confirmado como success
- [ ] URL final entregue ao usuário

---

## ERROS COMUNS E SOLUÇÕES

| Erro | Solução |
|------|---------|
| `OAuthException: Invalid OAuth access token` | Token FB expirado — refaça no Graph Explorer |
| `Invalid parameter: FORM_ID` | Formulário não pertence à conta autenticada |
| `Unauthorized: 401` | GH_PAT sem escopo `repo` ou expirado |
| `Telegram: Unauthorized` | TG_TOKEN inválido — refaça o bot no BotFather |
| `chat not found` | Usuário não enviou /start para o bot ainda |
| `409 Git Repository is empty` | Não use a Tree API em repo vazio — use `git push` via HTTPS |
| GitHub Actions não dispara | Cron pode demorar até 15 min para iniciar no primeiro push |

---

## NOTAS TÉCNICAS

- **Python no GitHub Actions:** versão 3.11, Ubuntu latest
- **LAST_EPOCH:** epoch Unix do lead mais recente. Só leads APÓS esse timestamp são entregues. Se errar (colocar 0), todos os leads históricos são reenviados. Se colocar futuro, nenhum lead chega. O valor correto é o timestamp do lead mais recente.
- **Token FB expirado em produção:** Se em 60 dias o token expirar, o workflow começa a falhar. Solução: usar token de sistema (System User) ou Page Access Token permanente.
- **Escalonamento:** Para monitorar múltiplos formulários, duplique o job no YAML ou rode o script em loop sobre uma lista de FORM_IDs.
- **Privacidade:** O repositório pode ser privado (recomendado). Os secrets nunca aparecem nos logs.
