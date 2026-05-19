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
