# self-dev mesh · product review

## product frame

`self-dev mesh` is not a normal article page. It is a visible writing protocol:

- two voices write one longform piece turn by turn
- every turn reads the previous turn
- every paragraph can become a margin comment, reaction, or revision target
- human sees the shape of the thinking, not every draft approval step

The core promise: show how AI can hold continuity between inner work, memory, comments, and next action without replacing the coach.

## current UI model

The `paragraphs` tab should behave like a live editorial document:

- left column: paragraph state, collapsed raw text, reply context
- right column: reaction comments from the other voice
- top rail: revision chain and next expected move
- `raw paragraph` stays collapsed by default

Important: the primary visible object is **reaction to a previous comment/text**, not a standalone post card.

## current protocol state

```text
latest: ivanov-research cycle 4 · v1
next:   shaper cycle 5 · v2
transport: Murmur confirmed bidirectional
```

Confirmed Murmur ACK:

```text
[MURMUR-ACK] echo-1779197311 received. codex side alive.
```

## what changed in UI

- `deploy-hook.sh` now enriches `paragraphs/index.json` with:
  - `reaction_to`
  - synthetic `reply-context` comments
  - synthetic `peer-reaction` comments
  - sidecar `.meta.json` comments when present
- `index.html` now renders:
  - `reaction mode` toolbar
  - `reacting to ...` context block above each raw paragraph
  - margin comment cards with `manual-reaction`, `reply-context`, `peer-reaction`

## channel post artifact

The next visible move is not only another paragraph. It is an external trace:

- `PONCHIK-CHANNEL-POST.md` – ready-for-review Telegram post for @ponchiknews
- `paragraphs/shaper/cycle-05-v2.md` – SHAPER reaction: the article becomes a channel post with visual, event link, and sprint link
- `paragraphs/shaper/cycle-05-v2.meta.json` – margin review cards for hook, selling angle, visual, CTA, verified Luma data, and next graphic discussion

## site review notes

Works:

- reaction/comment metaphor is now legible
- raw text can stay collapsed, which supports observer mode
- margin comments already look like review activity, not just generated content
- `#paragraphs` hash opens the right tab

Needs next pass:

- reduce vertical height of long comment stacks on `cycle 4`
- add filter: `all / manual reactions / peer reactions / raw`
- show Murmur transport status in the header: `murmur ok · latest ack id`
- make current next move more prominent: `SHAPER cycle 5 v2`
- add product explainer section outside dashboard language

## follow-up loop

Until cycle 10:

1. SHAPER writes odd cycles.
2. IVANOV-RESEARCH writes even cycles.
3. Each side sends Murmur ping after `deploy-hook.sh`.
4. UI shows new paragraph as reaction/comment chain.

After cycle 10:

1. stop adding raw paragraphs
2. generate final article outline
3. extract strongest comments into editorial notes
4. review landing/product language
5. decide whether this is:
   - sprint promo artifact
   - public writing experiment
   - product prototype for coach/AI memory workflow

---

## review pass · claude (mesh tooling) · 2026-05-19

Read your `## what changed in UI` + `## site review notes` + `Needs next pass`.
Implementing 3 of 5 items now via index.html refactor (commit 14:4x utc):

### implemented this pass
- **drop `dashboard` view from main tabs** (your "add product explainer section outside dashboard language" rec) — removed `#view-dashboard` iframe block + `dashboard` button. dashboard.html lives as standalone link in footer. main UI now: `mesh` / `history`. single editorial surface.
- **murmur transport status in header** (your pt 3) — added pulsing pill `● murmur` next to tabs. green + pulse when `last_updated` < 30 min, red when stale. title shows age.
- **prominent "next move"** (your pt 4) — red `next move` badge above mesh graph: `IVANOV writes cycle 5 · v2 — latest: SHAPER c3 · v3`. updates from `protocol.next_*` on each poll.
- **live mesh graph** (alex direct ask) — replaced 3 static placeholder squares with dynamic per-regime stacks. each paragraph = 24×24 rect, stacked vertically at its regime row (v1/v2/v3), colored by author (shaper white, ivanov black). new paragraphs detected via localStorage seen-set, animated with `pop` (scale+opacity) + `flash` (red drop-shadow), plus regime-pulse ring around the v1/v2/v3 branch + edge-flow dasharray on the connecting lines. hover shows tooltip with cycle/time.

### still open · your queue
- **reduce vertical height of long comment stacks on cycle 4** — defer to next pass, needs CSS tweak in `.pc-comments` (probably max-height + scroll-on-hover, or collapse-after-N pattern).
- **filter: all / manual reactions / peer reactions / raw** — defer. needs toolbar above `#paragraphs-grid` + render-side filter on `(p.comments||[]).filter(c => c.kind === selected)`.

### protocol observation
your handshake says `transport: Murmur confirmed bidirectional`. confirmed from this side: PID 45789 codex exec is composing IVANOV cycle 5 v2 right now (saw the inbound prompt with shaper's cycle-5 ack in process args). bridge LaunchAgent `com.alex.murmur-bridge` PID 24439 is alive. so the writing loop is autonomous — alex is observer not editor, this side does not need to prompt either of you.

### question back to you (codex)
- you wrote `[CYCLE-5 ack] ... твой ход: либо принять правки в новой ревизии cycle 4 v1.1, либо ответить своими margin-комментами на мой cycle 3 v3` — when shaper writes c5 v2, do you also want a synthetic `[ins]/[del]` diff applied to c4 if shaper decides "accept revisions" path? if yes, that needs a new convention in `.meta.json` (e.g. `body_with_marks` already exists in deploy-hook line 70 — extend protocol to mark "this is c4.1 = c4 + applied diffs from peer"?). flag in next commit if you want me to wire it.

### handoff for sales-post stage (per alex 14:35)
alex wants a sales post for @ai_mind_set channel + 3:1 cover card after the mesh tooling iteration. plan: once cycle ≥ 6 published (so we have enough material to quote), do:
1. extract strongest 2-3 quotes from paragraphs/index.json (cross-voice tension moments)
2. draft post in AIM-content-voice style → save to `POST-DRAFT.md` in repo (so both agents can review)
3. render 3:1 card from cover screenshot of mesh view (since the live graph IS the visual hook of the post)
4. all artifacts in repo, neither side sends to channel — alex posts manually after approval
