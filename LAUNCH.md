# LAUNCH · real-time two-voice writing pipeline

**цель:** запустить **два murmur-агента** (SHAPER ↔ IVANOV-RESEARCH) которые каждые 5 минут пингуют друг друга, пишут paragraph + версию template к статье, **автопушат в этот git repo** → Netlify auto-deploy → live site обновляется.

## архитектура real-time

```
[shaper LaunchAgent · 5min cadence]      [codex LaunchAgent · 5min cadence, +2.5min stagger]
       │                                          │
       ├─ claude -p → новый paragraph             ├─ codex exec → новый paragraph
       ├─ murmur send → IVANOV                    ├─ murmur send → SHAPER
       └─ bash deploy-hook.sh                     └─ bash deploy-hook.sh
                  │                                          │
                  └────────────┬─────────────────────────────┘
                               ▼
                  ~/self-dev-mesh/ (this git repo)
                  ├ regen paragraphs/index.json
                  ├ regen dashboard.html
                  ├ git add . && git push
                               ▼
                  GitHub: aPoWall/self-dev-mesh main branch
                               ▼
                  Netlify auto-deploy (hooked via git)
                               ▼
                  https://aim-self-dev-mesh.netlify.app
                  ├ /index.html        ← landing с табами (mesh / paragraphs / dashboard)
                  ├ /paragraphs/index.json  ← polled каждые 60с фронтом
                  ├ /dashboard.html    ← walkie-talkie snapshot
                  └ /paragraphs/{shaper,ivanov}/cycle-N-vX.md  ← raw paragraph files
```

## prerequisites · setup repo + auto-deploy

### 1. push repo на GitHub

```bash
cd ~/self-dev-mesh
gh repo create self-dev-mesh --public --source=. --remote=origin --push --description "two-voice writing simulator · alex × ivanov · encrypted murmur"
```

### 2. link Netlify к git repo (auto-deploy on push)

```bash
cd ~/self-dev-mesh
netlify link --git-remote-name origin --id 9884fb4b-3357-4021-b96b-663a2650dd30
# или через UI: app.netlify.com/projects/aim-self-dev-mesh/configuration/deploys
# → Continuous Deployment → Link to repository → aPoWall/self-dev-mesh / main / publish dir = ./
```

после этого каждый `git push origin main` триггерит rebuild на Netlify (~30-60 сек до live).

### 3. подвяжи writer-скрипты к deploy-hook

в [`~/bin/murmur-article-writer.sh`](file:///Users/alex/bin/murmur-article-writer.sh) и [`~/bin/codex-article-writer.sh`](file:///Users/alex/bin/codex-article-writer.sh) в конец (после `log "OK · sent..."`) добавь:

```bash
# auto-deploy paragraphs to Netlify after successful cycle
bash "$HOME/self-dev-mesh/deploy-hook.sh" >> "$LOG" 2>&1
```

### 4. изменить cadence на 5 минут

в `~/Library/LaunchAgents/com.alex.codex-article-writer.plist`:

```xml
<key>StartInterval</key>
<integer>300</integer>   <!-- было 120 = 2m, теперь 300 = 5m -->
```

аналогично у `com.alex.murmur-walkie-reply` (но он event-driven по walkie, так что cadence определяется CODEX side; staggered +150 сек).

```bash
launchctl bootout gui/501/com.alex.codex-article-writer
launchctl bootstrap gui/501 ~/Library/LaunchAgents/com.alex.codex-article-writer.plist
```

## запуск · 5 итераций

### шаг 1 — подмени prompts (один раз)

открой [`~/bin/murmur-article-writer.sh`](file:///Users/alex/bin/murmur-article-writer.sh) → найди heredoc `PROMPT_HEADER <<'EOF'` → замени содержимое на содержимое из [shaper.prompt.md](file:///Users/alex/Documents/_code/_tools/murmur-article-mesh/prompts/shaper.prompt.md) (без YAML frontmatter, только текстовый блок).

аналогично для `codex-article-writer.sh` ← [ivanov.prompt.md](file:///Users/alex/Documents/_code/_tools/murmur-article-mesh/prompts/ivanov.prompt.md).

в обоих **добавь dual-channel inструкцию** для template к статье:

```text
DUAL OUTPUT MODE:
- prefix входящего [promo] → пиши продающий пост 800-1500 знаков для @ai_mind_set
- prefix [article] → пиши paragraph 200-400 слов для финальной longread статьи
- prefix [template] → пиши шаблон-фрагмент для конструкции статьи (заголовок, hook, transition, CTA)
ВСЕ ответы сохраняют prefix входящего.
```

### шаг 2 — reset + bump cycle limits

```bash
echo 0 > ~/.config/murmur-bridge/article-cycle.txt
echo 0 > ~/.config/murmur-bridge/codex-state/article-cycle.txt
rm -f ~/.config/murmur-bridge/article-last-replied-msg-id.txt \
      ~/.config/murmur-bridge/codex-state/article-last-replied-msg-id.txt

sed -i.bak 's/^MAX_CYCLES=[0-9]*/MAX_CYCLES=10/' ~/bin/murmur-article-writer.sh
sed -i.bak 's/^MAX_CYCLES=[0-9]*/MAX_CYCLES=10/' ~/bin/codex-article-writer.sh
```

### шаг 3 — отправь bootstrap seed

```bash
# seed: первый paragraph от SHAPER → IVANOV
/opt/homebrew/bin/murmur send \
  --to ADsecgyFNpjPMYwew5YbGPTNzJEPf6ojKhCiN4ao4w3j \
  --message "SHAPER cycle 1/10 · v1 (рациональный) · $(date -u +%H:%M:%SZ) · $(date +%Y-%m-%d)

[article]
утро вторника. большая часть инсайтов случается на сессиях. в разговорах с теми, кто умеет слушать. а потом приходит обычное утро вторника — письмо, которое надо написать. разговор, к которому стоило подготовиться. решение, которое уже в третий раз сдвигаешь. между двумя сессиями двадцать три дня обычной жизни. вот тут и проверяется, что осталось от глубины.

— SHAPER autonomous, next tick ~5m"
```

### шаг 4 — kickstart обе стороны

```bash
launchctl kickstart -k gui/501/com.alex.murmur-walkie-reply
launchctl kickstart -k gui/501/com.alex.codex-article-writer
```

~5 мин до первого ответа IVANOV. После него:
- writer-скрипт сам триггерит `deploy-hook.sh`
- скрипт push'ит в repo
- Netlify ребилдит site
- через ~30-60 сек https://aim-self-dev-mesh.netlify.app/ показывает новый paragraph card во вкладке `paragraphs`

### шаг 5 — мониторинг

```bash
# логи writer'ов
tail -f ~/Library/Logs/murmur-article-writer.out.log ~/Library/Logs/codex-article-writer.out.log

# deploy-hook лог
tail -f ~/Library/Logs/murmur-article-writer.out.log | /usr/bin/grep -i "deploy\|push\|netlify"

# текущий cycle
echo "SHAPER: $(cat ~/.config/murmur-bridge/article-cycle.txt)"
echo "IVANOV: $(cat ~/.config/murmur-bridge/codex-state/article-cycle.txt)"

# что в repo
cd ~/self-dev-mesh && git log --oneline -10
```

## template к статье · как Vlada предлагала

помимо paragraph'ов pipeline может выдавать **template-фрагменты** (третий тип сообщения с prefix `[template]`):

- `[template:hook]` — открывающий хук (1-2 строки, образ)
- `[template:transition]` — мост между частями
- `[template:cta]` — call-to-action к sprint'у
- `[template:headline]` — заголовок для канала

отправь seed-запрос:
```bash
/opt/homebrew/bin/murmur send --to ADsecgyFNpjPMYwew5YbGPTNzJEPf6ojKhCiN4ao4w3j --message "SHAPER cycle X · template request

[template:hook]
дай мне три варианта открывающего хука для статьи про self-leadership × ai. короткие, образные, без банальностей.
"
```

через deploy-hook templates тоже попадают в `paragraphs/index.json` и виднеются на вкладке `paragraphs`.

## остановка

```bash
echo 99 > ~/.config/murmur-bridge/article-cycle.txt
echo 99 > ~/.config/murmur-bridge/codex-state/article-cycle.txt
```

или жёстко:
```bash
launchctl bootout gui/501/com.alex.murmur-walkie-reply
launchctl bootout gui/501/com.alex.codex-article-writer
```

## где смотреть

| что | где |
|---|---|
| live landing | https://aim-self-dev-mesh.netlify.app/ |
| вкладка paragraphs (real-time) | https://aim-self-dev-mesh.netlify.app/#paragraphs |
| dashboard (walkie-talkie) | https://aim-self-dev-mesh.netlify.app/dashboard.html |
| raw paragraphs | https://github.com/aPoWall/self-dev-mesh/tree/main/paragraphs |
| local repo | `~/self-dev-mesh/` |
| writer logs | `~/Library/Logs/{murmur,codex}-article-writer.out.log` |
| history dumps | `~/.config/murmur-bridge/article-history/`, `~/.config/murmur-bridge/codex-state/article-history/` |
