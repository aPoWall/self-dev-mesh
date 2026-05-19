#!/bin/bash
# deploy-hook.sh — called by murmur writer scripts after each successful cycle.
# Regenerates paragraphs/index.json + dashboard.html, git commit + push.

set -uo pipefail
REPO="$HOME/self-dev-mesh"
SHAPER_HIST="$HOME/.config/murmur-bridge/selfdev/shaper-history"
CODEX_HIST="$HOME/.config/murmur-bridge/selfdev/ivanov-history"
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
(PARAGRAPHS / "ivanov-research").mkdir(exist_ok=True)

def item_from_file(p, author, cycle, regime):
    body = p.read_text(errors="ignore").strip()
    mtime = datetime.fromtimestamp(p.stat().st_mtime, tz=timezone.utc).isoformat()
    slug = f"cycle-{int(cycle):02d}-{regime}.md"
    return {"author":author,"cycle":int(cycle),"regime":regime,
            "time":mtime[11:19]+" utc","iso":mtime,"body":body,
            "file":f"paragraphs/{author.lower()}/{slug}"}

def harvest_repo(author):
    out = []
    for p in sorted((PARAGRAPHS / author.lower()).glob("cycle-*-v*.md")):
        m = re.match(r"cycle-(\d+)-(v\d+)\.md", p.name)
        if not m: continue
        out.append(item_from_file(p, author, m.group(1), m.group(2)))
    return out

def harvest(history_dir, author):
    out = []
    for p in sorted(Path(history_dir).glob("cycle-*-outgoing-v*.md")):
        m = re.match(r"cycle-(\d+)-outgoing-(v\d+)\.md", p.name)
        if not m: continue
        cycle, regime = m.group(1), m.group(2)
        slug = f"cycle-{int(cycle):02d}-{regime}.md"
        item = item_from_file(p, author, cycle, regime)
        (PARAGRAPHS / author.lower() / slug).write_text(item["body"])
        out.append(item)
    return out

items = {}
for item in harvest_repo("shaper") + harvest_repo("ivanov-research"):
    items[(item["author"], item["cycle"], item["regime"])] = item
for item in harvest("$SHAPER_HIST", "shaper") + harvest("$CODEX_HIST", "ivanov-research"):
    items[(item["author"], item["cycle"], item["regime"])] = item

paragraphs = sorted(items.values(), key=lambda p: (p["cycle"], p["author"]))
latest = paragraphs[-1] if paragraphs else None
next_author = None
next_regime = None
next_cycle = 1
if latest:
    next_author = "ivanov-research" if latest["author"] == "shaper" else "shaper"
    next_cycle = latest["cycle"] + 1
    next_regime = {"v1":"v2","v2":"v3","v3":"v1"}.get(latest["regime"], "v1")

data = {"last_updated": datetime.now(timezone.utc).isoformat(),
        "protocol": {
            "mode": "agent-to-agent",
            "human_role": "observer/checking",
            "latest_author": latest["author"] if latest else None,
            "latest_cycle": latest["cycle"] if latest else None,
            "latest_regime": latest["regime"] if latest else None,
            "next_author": next_author,
            "next_cycle": next_cycle,
            "next_regime": next_regime,
        },
        "paragraphs": paragraphs}
(PARAGRAPHS / "index.json").write_text(json.dumps(data, ensure_ascii=False, indent=2))
print(f"index.json: {len(data['paragraphs'])} paragraphs")
PYEOF

# Dashboard regen disabled — selfdev-render.py pulls from other-project peers
# (CODEX-LOCAL/ARTICLE/JARVIS). self-dev-mesh uses paragraphs/index.json directly.

cd "$REPO"
if git diff --quiet && git diff --staged --quiet; then
    log "no changes, skip"; exit 0
fi
CYC="shaper=$(cat $HOME/.config/murmur-bridge/selfdev/shaper-cycle.txt 2>/dev/null || echo ?) ivanov=$(cat $HOME/.config/murmur-bridge/selfdev/ivanov-cycle.txt 2>/dev/null || echo ?)"
git add . >> "$LOG" 2>&1
git commit -m "cycle update · $(ts) · $CYC" --no-verify >> "$LOG" 2>&1
git push origin main >> "$LOG" 2>&1 && log "✓ pushed · netlify rebuild triggered" || log "✗ push failed"
