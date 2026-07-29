#!/usr/bin/env bash
# Regenerate the profile's live telemetry and publish it.
#
# A GitHub README cannot run JavaScript, so "live" means: regenerate the
# shields.io endpoint JSONs and the SVG chart on a timer, commit, push. The
# profile then reports itself instead of rotting into a stale hand-typed claim.
#
# Runs hourly via com.cmc.profile.refresh. Safe to run by hand.
set -euo pipefail

PROFILE="${PROFILE_REPO:-$HOME/projects/cmc-veup-profile}"
FLIGHTDECK="${FLIGHTDECK_REPO:-$HOME/projects/flightdeck}"
RANK="${VIBERANK_RANK:-11}"
TIER="${VIBERANK_TIER:-Supernova}"

cd "$FLIGHTDECK"
python3 -m flightdeck.cli collect --quiet
python3 -m flightdeck.cli badges --out "$PROFILE" --rank "$RANK" --tier "$TIER" --days 30 >/dev/null

cd "$PROFILE"

# The prose summary quotes the same numbers as the badges, so it is generated
# from the same metrics rather than retyped. A README that says "these are not
# estimates" while carrying stale hand-typed figures is precisely the drift
# flightdeck exists to catch.
python3 - <<'PY'
import json, pathlib
m = json.loads(pathlib.Path("badges/metrics.json").read_text())
body = (
    "> [!NOTE]\n"
    f"> **{m['tokens']/1e9:.1f}B tokens across {m['days_covered']} days**, on "
    f"{m['models']} models from {m['vendors']} labs, {m['cache_pct']:.0f}% of it served\n"
    f"> from cache. About {m['subagent_pct']:.0f}% was spent by subagents rather than by me\n"
    "> typing. These are not estimates — they are reconciled from the transcripts on\n"
    "> disk by [flightdeck](https://github.com/cmc-veup/flightdeck), and this paragraph\n"
    "> is regenerated hourly from the same data as the badges above."
)
table = "\n".join([
    "| | |",
    "|---|---|",
    f"| **Scale** | {m['peak_sessions']} sustained concurrent agent sessions at peak"
    f"{' on ' + m['peak_day'] if m.get('peak_day') else ''}. Not a burst — sustained"
    " across a working day, against a shared work queue. |",
    f"| **Fan-out** | {m['subagent_pct']:.0f}% of recent tokens are spent by subagents."
    " Much of the work is delegated by other agents, not by me. |",
    f"| **Provider diversity** | {m['models']} models across {m['vendors']} labs. No"
    " single-vendor dependency, and routing is a decision the model makes, not a"
    " hardcoded table. |",
    f"| **Cost discipline** | {m['cache_pct']:.0f}% of tokens served from cache. Cache is"
    " the difference between a swarm being affordable and being a science project. |",
    "| **Accounting** | Every token attributed to a model, an account, a session, and a"
    " cost — priced at the rate in force *when it was spent*, not today's rate. |",
])

p = pathlib.Path("README.md"); t = p.read_text()
for a, b, blk in (("<!-- BEGIN LIVE-SUMMARY -->", "<!-- END LIVE-SUMMARY -->", body),
                  ("<!-- BEGIN LIVE-TABLE -->", "<!-- END LIVE-TABLE -->", table)):
    i, j = t.index(a), t.index(b)
    t = t[:i] + a + "\n" + blk + "\n" + t[j:]
p.write_text(t)
print("live blocks regenerated")
PY

git add badges usage.svg README.md
# Nothing changed is the common case on a quiet hour — not an error.
if git diff --cached --quiet; then
  echo "profile: no change"
  exit 0
fi
git commit -qm "profile: refresh telemetry $(date -u +%Y-%m-%dT%H:%MZ)"
git push -q origin main
echo "profile: published $(git rev-parse --short HEAD)"
