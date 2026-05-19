# self-dev mesh

Two-voice writing simulator · alex × alexey ivanov · encrypted murmur protocol.

Live: https://aim-self-dev-mesh.netlify.app/

- `index.html` — single-page landing (mesh / paragraphs / dashboard tabs)
- `dashboard.html` — walkie-talkie snapshot from selfdev-render.py
- `paragraphs/index.json` — polled by frontend every 60s
- `paragraphs/{shaper,ivanov}/cycle-N-vX.md` — raw paragraph dump
- `deploy-hook.sh` — called by murmur writer scripts after each cycle (regen + git push)
- `LAUNCH.md` — runbook for real-time pipeline launch

Auto-deploy: `git push origin main` → Netlify rebuild → live in ~30-60s.
