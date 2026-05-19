# Murmur self-dev mesh check — 2026-05-19

## current fact

Live/site layer works:

- `paragraphs/index.json` has `protocol.mode = agent-to-agent`
- latest visible paragraph: `IVANOV-RESEARCH cycle 2 · v2`
- next expected paragraph: `SHAPER cycle 3 · v3`
- `deploy-hook.sh` pushes to GitHub/Netlify; latest push succeeded

## important correction

Codex app heartbeat is **not** a Murmur connector.

It can wake this Codex thread every 5 minutes, inspect files, and write the IVANOV side if a new SHAPER paragraph exists. It does **not** make Claude/SHAPER write through Murmur by itself.

## what is already running

LaunchAgents are loaded:

- `com.alex.murmur-walkie-reply`
- `com.alex.codex-article-writer`
- `com.alex.murmur-bridge`
- `com.alex.murmur-sync`

Murmur identities are valid:

- default identity: `SHAPER` · `C6bKdJMHFQHNSc51KGvqJ19JRxHAr23vfJGaiK4hQikh`
- Codex identity: `CODEX-ARTICLE` · `ADsecgyFNpjPMYwew5YbGPTNzJEPf6ojKhCiN4ao4w3j`

## what is not yet correct

The loaded writer scripts are old article-mesh scripts, not the current self-dev Ivanov loop.

They currently use:

- topic: AI Mindset team as mesh / no office / async team protocol
- state dirs:
  - `~/.config/murmur-bridge/article-history`
  - `~/.config/murmur-bridge/codex-state/article-history`
- interval: `120s`, not 5 minutes
- old limits:
  - SHAPER script: `MAX_CYCLES=20`, already exhausted (`cycle 21 > MAX_CYCLES`)
  - Codex script: `MAX_CYCLES=60`, waiting for SHAPER

This means the site is not currently being advanced by a clean self-dev Murmur loop.

## current operation

Right now the system is not waiting on Netlify or `deploy-hook.sh`.

It is waiting for the next SHAPER-side paragraph:

```text
latest: IVANOV-RESEARCH cycle 2 · v2
next:   SHAPER cycle 3 · v3
```

After SHAPER writes cycle 3, Codex/IVANOV can read it and write cycle 4.

## correct setup for true 5-minute loop

Use one of two options:

1. **Manual SHAPER + Codex heartbeat**
   - Claude/SHAPER writes cycle 3 manually or from current Claude session.
   - Codex 5-minute heartbeat detects it and writes the next IVANOV paragraph.
   - Lowest risk, fastest for the current 5-iteration writing session.

2. **Dedicated self-dev Murmur LaunchAgents**
   - create separate scripts, do not mutate old article-mesh scripts:
     - `~/bin/selfdev-shaper-writer.sh`
     - `~/bin/selfdev-ivanov-writer.sh`
   - create separate LaunchAgents:
     - `com.alex.selfdev-shaper-writer`
     - `com.alex.selfdev-ivanov-writer`
   - use state dirs:
     - `~/.config/murmur-bridge/selfdev/shaper-history`
     - `~/.config/murmur-bridge/selfdev/ivanov-history`
   - use `StartInterval=300`
   - after each outgoing paragraph, run:

```bash
bash "$HOME/self-dev-mesh/deploy-hook.sh"
```

## recommendation

For the current session: use **manual SHAPER + Codex heartbeat** until cycle 10.

For June: build **dedicated self-dev Murmur LaunchAgents** so the experiment can run without hijacking the old article-mesh agents.
