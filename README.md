<div align="center">

# Christian McCaffrey

**CEO, [VeUP](https://veup.com)** · Florida

*Client delivery runs on an agent swarm. The tooling is public and the numbers are audited.*

[![tokens](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcmc-veup%2Fcmc-veup%2Fmain%2Fbadges%2Ftokens.json)](https://github.com/cmc-veup/flightdeck)
[![subagent share](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcmc-veup%2Fcmc-veup%2Fmain%2Fbadges%2Fsubagents.json)](https://github.com/cmc-veup/flightdeck)
[![swarm](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcmc-veup%2Fcmc-veup%2Fmain%2Fbadges%2Fswarm.json)](https://github.com/cmc-veup/flightdeck)
[![models](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcmc-veup%2Fcmc-veup%2Fmain%2Fbadges%2Fmodels.json)](https://github.com/cmc-veup/flightdeck)
[![cache](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcmc-veup%2Fcmc-veup%2Fmain%2Fbadges%2Fcache.json)](https://github.com/cmc-veup/flightdeck)
[![viberank](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcmc-veup%2Fcmc-veup%2Fmain%2Fbadges%2Fviberank.json)](https://viberank.app/profile/cmc-veup)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-2b2b2b?style=flat-square&logo=linkedin&logoColor=0A66C2)](https://www.linkedin.com/in/YOUR-HANDLE)
[![VeUP](https://img.shields.io/badge/veup.com-2b2b2b?style=flat-square&logo=google-chrome&logoColor=white)](https://veup.com)
[![viberank](https://img.shields.io/badge/viberank%20%2311-2b2b2b?style=flat-square&logo=trophy&logoColor=f0c674)](https://viberank.app/profile/cmc-veup)

`Multi-Agent Delivery` · `Agentic Coding` · `AWS` · `Rust` · `Swift` · `Local-First AI`

</div>

---

<div align="center">
<img src="usage.svg" alt="Daily token usage over the last 30 days, split between main sessions and subagents" width="820">
</div>

Blue is work I direct. Amber is work the swarm directs on its own — about half of it.

---

## The numbers above are live

They are not hand-typed. Every badge and the chart are regenerated hourly by
[**flightdeck**](https://github.com/cmc-veup/flightdeck), a collector I wrote after discovering
that every usage dashboard on my machine was wrong in a different way — one was reading a cache
that had not updated in four months, another counted characters instead of tokens, and all of
them either double-counted subagent transcripts or could not see them at all.

It reads the transcripts that Claude Code, Codex, Grok and everything behind a Claude Code shell
already write to disk, and answers the question those tools kept getting wrong: how many tokens,
on which model, from which account, at what cost, and how much of it is fan-out.

The leaderboard entry is the same data, submitted from the same tool:
**[viberank.app/profile/cmc-veup](https://viberank.app/profile/cmc-veup)**.

## What I'm building

| | |
|---|---|
| [**flightdeck**](https://github.com/cmc-veup/flightdeck) | Truthful multi-provider token accounting for local AI coding agents. Recovers months that Claude Code deleted, reports subagent spend as a first-class dimension, and submits to the leaderboard without laundering the numbers through a tool that regenerates them. |

More to come — a Zero Framework Cognition skill, and a write-up on using the Claude CLI as a
subscription-billed inference transport for backend services.

## What I do

I run [VeUP](https://veup.com), an AWS partner. Day to day that means client delivery,
and increasingly it means delivery executed by agent swarms rather than by hand — which is why
I care so much about measuring them honestly. A number you cannot audit is a number you cannot
manage, and most of this industry is currently reporting numbers nobody has checked.
