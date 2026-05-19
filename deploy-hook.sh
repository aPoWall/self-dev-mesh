#!/bin/bash
# deploy-hook.sh — called by murmur writer scripts after each successful cycle.
# Regenerates paragraphs/index.json + dashboard.html, git commit + push.

set -uo pipefail
REPO="$HOME/self-dev-mesh"
SHAPER_HIST="$HOME/.config/murmur-bridge/article-history"
CODEX_HIST="$HOME/.config/murmur-bridge/codex-state/article-history"
LOG="$HOME/Library/Logs/self-dev-mesh-deploy.log"
ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log() { echo "[$(ts)] $*" >> "$LOG"; }

[ -d "$REPO" ] || { log "repo missing"; exit 0; }
log "── deploy-hook tick ──"

python3 - <<PYEOF
import json, re
from pathlib import Path
from datetime import datetime, timezone

REPO = Path("$REPO")
PARAGRAPHS = REPO / "paragraphs"
PARAGRAPHS.mkdir(exist_ok=True)
(PARAGRAPHS / "shaper").mkdir(exist_ok=True)
(PARAGRAPHS / "ivanov").mkdir(exist_ok=True)

def harvest(history_dir, author):
    out = []
    for p in sorted(Path(history_dir).glob("cycle-*-outgoing-v*.md")):
        m = re.match(r"cycle-(\d+)-outgoing-(v\d+)\.md", p.name)
        if not m: continue
        cycle, regime = m.group(1), m.group(2)
        body = p.read_text(errors="ignore").strip()
        mtime = datetime.fromtimestamp(p.stat().st_mtime, tz=timezone.utc).isoformat()
        slug = f"cycle-{int(cycle):02d}-{regime}.md"
        (PARAGRAPHS / author.lower() / slug).write_text(body)
        out.append({"author":author,"cycle":int(cycle),"regime":regime,
                    "time":mtime[11:19]+" utc","iso":mtime,"body":body,
                    "file":f"paragraphs/{author.lower()}/{slug}"})
    return out

shaper = harvest("$SHAPER_HIST", "shaper")
ivanov = harvest("$CODEX_HIST", "ivanov-research")
data = {"last_updated": datetime.now(timezone.utc).isoformat(),
        "paragraphs": sorted(shaper + ivanov, key=lambda p: (p["cycle"], p["author"]))}
(PARAGRAPHS / "index.json").write_text(json.dumps(data, ensure_ascii=False, indent=2))
print(f"index.json: {len(data['paragraphs'])} paragraphs")
PYEOF

# Regen dashboard
if [ -f /Users/alex/bin/selfdev-render.py ]; then
    python3 /Users/alex/bin/selfdev-render.py >> "$LOG" 2>&1
    if [ -f /tmp/selfdev.html ]; then
        cp /tmp/selfdev.html "$REPO/dashboard.html"
        python3 -c "import re; p='$REPO/dashboard.html'; h=open(p).read(); h=re.sub(r'<script>.*?</script>','<!-- static -->',h,flags=re.DOTALL); open(p,'w').write(h)"
    fi
fi

cd "$REPO"
if git diff --quiet && git diff --staged --quiet; then
    log "no changes, skip"; exit 0
fi
CYC="shaper=$(cat $HOME/.config/murmur-bridge/article-cycle.txt 2>/dev/null || echo ?) ivanov=$(cat $HOME/.config/murmur-bridge/codex-state/article-cycle.txt 2>/dev/null || echo ?)"
git add . >> "$LOG" 2>&1
git commit -m "cycle update · $(ts) · $CYC" --no-verify >> "$LOG" 2>&1
git push origin main >> "$LOG" 2>&1 && log "✓ pushed · netlify rebuild triggered" || log "✗ push failed"
