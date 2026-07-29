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

[![LinkedIn](https://img.shields.io/badge/LinkedIn-2b2b2b?style=flat-square&logo=linkedin&logoColor=0A66C2)](https://www.linkedin.com/in/cbxmc/)
[![VeUP](https://img.shields.io/badge/veup.com-2b2b2b?style=flat-square&logo=google-chrome&logoColor=white)](https://veup.com)


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

## What I'm building

### Public

| | |
|---|---|
| [**flightdeck**](https://github.com/cmc-veup/flightdeck) | Truthful multi-provider token accounting for local AI coding agents. Recovers months that Claude Code deleted, reports subagent spend as a first-class dimension, and submits to the leaderboard without laundering the numbers through a tool that regenerates them. |
| [**zfc**](https://github.com/cmc-veup/zfc-skill) | Zero Framework Cognition — an agent skill that keeps judgment in the model and heuristics out of the application. Every regex you write against model output is a bet against the next model. |

### Not public

Most of the work isn't open source — it either encodes something client-specific or isn't
finished enough to hand someone. The shape of it:

| | |
|---|---|
| **Tropical attention at the edge** | Max-plus idempotent attention in place of softmax: every multiply collapses to add-and-compare, so inference maps onto a systolic array with structurally predictable latency and no floating-point drift — full fidelity, sub-millisecond, on hardware that has no business running a model. Exact routes fall out of it, which means real attributions and an ℓ∞ robustness certificate rather than a saliency map. Built on [model_guided_research](https://github.com/Dicklesworthstone/model_guided_research); carried into on-device safety inference and a scoring engine. |
| **Swarm orchestration** | Running agents by the hundred against a shared work queue: leases, federation, recovery, and the accounting that proves what they actually cost. |
| **Meeting intelligence** | Local-first Mac capture. Transcription and diarization on-device; audio never leaves the machine, only text reaches a model. |
| **A unified tool server** | One MCP surface over the dozen-odd business systems delivery actually runs on, so an agent gets a single contract instead of a dozen auth dances. |
| **Autonomous operating reports** | Agents that assemble the monthly estate review, where every claim has to link to a receipt or it doesn't ship. |
| **Delivery practice** | Forward-deployed engineering, AI-DLC, and living roadmaps that stay current because agents maintain them rather than people remembering to. |

What generalizes gets extracted and published here. What encodes a client stays in.

## What I do

I run [VeUP](https://veup.com), an AWS partner. The work I care about is at the frontier:
delivery executed by agent swarms, measured honestly enough to trust.
