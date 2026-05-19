---
status: handoff · pending
context_from: claude code session 2026-05-19 17:00–18:20
target_session: fresh window, full context
priority: medium (cosmetic, not blocking)
---

# HANDOFF · localhost:18790/share redesign

## Goal
Apply mesh-page aesthetic (https://aim-self-dev-mesh.netlify.app/) to local `share.html` dashboard at http://localhost:18790/share. Pure visual upgrade.

## Files
- **Source generator**: `/Users/alex/bin/share-render.py` (767 lines, template inline)
- **Output**: `/Users/alex/Documents/_code/_generators/shaper-walkie-talkie-dashboard/share.html`
- **Server**: `/Users/alex/bin/share-live-server.py` (port 18790)
- **Reference design**: `/Users/alex/self-dev-mesh/index.html` (especially comm-graph SVG section + HUMAN node animation block)

## What to lift from mesh page

### 1. HUMAN node animation
From `~/self-dev-mesh/index.html` search for `human-pulse-ring` + `human-heart` CSS + the `<g class="cg-node">` for HUMAN. Three SVG circles:
- 2 staggered `human-pulse-ring` (red expanding-fading 2.8s loop, second at delay 1.4s)
- 1 `human-heart` red dot (3→6→3 px pulse 1.4s)

Add HUMAN as 4th central node in share-render NODES dict (currently has shaper/codex/jarvis triangle — add HUMAN observer at top-center, push others slightly down).

### 2. Team avatars as clipped images
Replace plain `<circle>` nodes with `<image href="..." clip-path="url(#clip-...)">` pattern from mesh page. Existing avatars:
- alex / shaper → `assets/alex-avatar.png` (already in /self-dev-mesh/assets/)
- ivanov → `assets/ivanov-avatar.jpg`
- jarvis-opus → need photo or stylized B&W silhouette
- new Murmur peer avatars → user wants team avatars added (Vlada, Ira, Dan, Katya, etc — pull from `/Users/alex/Library/CloudStorage/Dropbox/notes/AI mindset {shared}/ai-mindset-2026/Org/HR/roles/` or `/Users/alex/My Drive/AI mindset/pics/`)

### 3. Stat-card upgrade (A/B/C/T pattern)
Current `.block .num` corner-badge → upgrade to mesh-page `.stat-card .sc-letter` pattern (filled black circle with letter, top-left).

### 4. Observation dots from HUMAN
4 small grey dots traveling from HUMAN down to each agent node via `<animateMotion>` along defined `<path>` (5s loop, staggered begin times).

### 5. Color discipline
Keep #c43838 red as accent (NEXT callouts, pulse-rings, edge-flow on fresh activity). Everything else B&W.

## Murmur peers — current state
From share-render line 348:
```python
NODES = {
    "shaper": {"x": 280, "y": 460, "id": "C6bKdJ…aiKh"},
    "codex":  {"x": 920, "y": 460, "id": "ADsecg…o4w3j"},
    "jarvis": {"x": 600, "y": 110, "id": "786e3a…JNed"},
}
```

For team-onboard expansion (see `Org/Infrastructure/{AIM} {runbook} Murmur Team Onboard – 2026-05-18.md`):
- Add Vlada peer ID when онбордится
- Add Ira peer ID when онбордится
- etc — pulled from murmur-bridge config

## Quick-win sequence (suggested 30-min pass)

1. **Pull last share-render.py** + understand current SVG structure (lines 346–490)
2. **Add HUMAN node** at center-top (x=600, y=60, r=34) with pulse-ring + heart-beat
3. **Add 4 observation dots** flowing from HUMAN → shaper/codex/jarvis
4. **Wrap 3 existing nodes in `<image clipPath>`** to show avatar photos
5. **Refresh** via `~/bin/share-render.py` and reload localhost:18790/share to verify
6. **(optional)** Stat-card upgrade A/B/C/T pattern in `.stats` section

## CSS to add (lift verbatim from mesh page)

```css
.human-pulse-ring{fill:none;stroke:#c43838;stroke-width:1.5;opacity:0;animation:human-ring 2.8s ease-out infinite}
@keyframes human-ring{0%{r:34;opacity:.6;stroke-width:2}100%{r:62;opacity:0;stroke-width:0.5}}
.human-heart{fill:#c43838;animation:human-beat 1.4s ease-in-out infinite}
@keyframes human-beat{0%,100%{r:3;opacity:.6}50%{r:6;opacity:1}}
```

## Context from this session

User said: «давай мы вот этот локальный дашборд также локально переделаем в виде более красивой визуализации, которая появилась у нас на MESH'e. На MESH'e было всё красиво. Давай в таком формате тоже подтянем аватары команды и соответствующих MURMUR-соседских ребят. Сделаем переделать локальный дашборд чисто визуал, красиво.»

Translation: take the beautiful viz from mesh page, apply to local share dashboard. Pull team avatars + Murmur peer avatars. Pure visual rework.

## Status

- mesh page (self-dev-mesh.netlify.app) — current version is good baseline
- local dashboard (share.html via share-render.py) — currently functional but visually less refined
- No urgency — visual polish task, can wait until next focused session
- Context budget exhausted in current Claude session (99% used) — defer to fresh window
