#!/usr/bin/env bash
# Regenerate the profile's live telemetry and publish it.
#
# A GitHub README cannot run JavaScript, so "live" means: regenerate the
# shields.io endpoint JSONs and the SVG chart on a timer, commit, push. The
# profile then reports itself instead of rotting into a stale hand-typed claim.
#
# Runs hourly via com.cmc.profile.refresh. Safe to run by hand.
set -euo pipefail

# `timeout` is NOT in macOS base (Homebrew coreutils) and launchd's PATH does
# not include /opt/homebrew/bin — calling it bare exits 127. Resolve it, and
# degrade to running unguarded rather than not running at all.
TIMEOUT=""
for _c in /opt/homebrew/bin/timeout /usr/local/bin/timeout /usr/bin/timeout; do
  [ -x "$_c" ] && { TIMEOUT="$_c"; break; }
done
run_capped() {   # run_capped <seconds> <cmd...>
  local secs=$1; shift
  if [ -n "$TIMEOUT" ]; then "$TIMEOUT" "$secs" "$@"; else "$@"; fi
}

# `gh` is Homebrew too, and the SAME launchd PATH that hides `timeout` hides it.
# A bare `gh auth token` under launchd resolves to nothing, so the owner-token
# lookup below returned empty on EVERY scheduled run and silently took the
# ambient-auth fallback -- the exact dependency on interactive state that the
# fallback exists to avoid. It only looked fine because cmc-veup happened to be
# the active account; the next `gh auth switch` froze the badges with a 403.
# Resolve it explicitly, like TIMEOUT.
GH=""
for _c in /opt/homebrew/bin/gh /usr/local/bin/gh /usr/bin/gh; do
  [ -x "$_c" ] && { GH="$_c"; break; }
done

# Hard ceilings on every step that touches the DB or the network.
#
# A `badges` run wedged for 69 MINUTES on 2026-08-14 holding the SQLite write
# lock (22s of CPU across the whole hour -- hung, not working). Every collect
# behind it died with "database is locked", so the badges stopped advancing and
# the profile appeared to freeze. Nothing detected it: launchd happily starts
# the next copy on schedule and never notices the last one never returned.
#
# A timer that cannot fail is not a timer. `timeout` converts a hang from a
# silent permanent outage into one skipped cycle.

PROFILE="${PROFILE_REPO:-$HOME/projects/cmc-veup-profile}"
FLIGHTDECK="${FLIGHTDECK_REPO:-$HOME/projects/flightdeck}"
# Rank and tier come from the live board, never a constant. They were hardcoded
# to "#11 · Supernova" and kept republishing that after the real position had
# moved to #12 — a stale claim on the one badge whose whole purpose is a live
# position. If the fetch fails we keep the previous badge rather than assert a
# number we did not just verify.
# rank-watch prints its human summary on stderr and JSON on stdout, so parse
# the JSON — grepping the text after 2>/dev/null silently matches nothing.
# `|| true`: a board fetch that fails must not abort the whole refresh under
# `set -e`. An empty RANK is handled below by keeping the previous badge.
RANK=$(python3 "$HOME/.claude/skills/flightdeck-operations/scripts/rank-watch.py" \
         --user "${VIBERANK_USER:-cmc-veup}" 2>/dev/null | python3 -c "
import json,sys
t=sys.stdin.read()
try: print(json.loads(t[t.index('{'):]).get('rank') or '')
except Exception: print('')" 2>/dev/null || true)

# Tier is NOT in the board payload — it is a viberank UI band, so it cannot be
# fetched and stays configurable. Rank is the part that actually moves.
TIER="${VIBERANK_TIER:-Supernova}"

cd "$FLIGHTDECK"
run_capped 600 python3 -m flightdeck.cli collect --quiet || echo "profile: collect timed out or skipped — badges will use the current DB" >&2
# No rank fetched: regenerate every other badge and leave viberank.json as it
# was. Publishing a guessed position is worse than publishing yesterday's.
if [ -n "$RANK" ]; then
  run_capped 300 python3 -m flightdeck.cli badges --out "$PROFILE" --rank "$RANK" --tier "$TIER" --days 30 >/dev/null
else
  echo "profile: rank fetch failed — keeping the previous viberank badge" >&2
  cp -f "$PROFILE/badges/viberank.json" /tmp/viberank.keep 2>/dev/null || true
  run_capped 300 python3 -m flightdeck.cli badges --out "$PROFILE" --days 30 >/dev/null
  cp -f /tmp/viberank.keep "$PROFILE/badges/viberank.json" 2>/dev/null || true
fi

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
    f"> **{m['tokens']/1e9:.1f}B tokens** over {m['days_active']} active days · "
    f"{m['models']} models · {m['vendors']} labs · {m['cache_read_pct']:.0f}% cache reads · "
    f"{m['subagent_pct']:.0f}% spent by subagents.\n"
    "> Reconciled by [flightdeck](https://github.com/cmc-veup/flightdeck) from transcripts on "
    "disk, plus archives of the\n> months Claude Code deleted. April is still gone, so this is "
    "a floor. Regenerated hourly."
)

table = "\n".join([
    "| | |",
    "|---|---|",
    f"| **Scale** | 0 → {m['wave_ceiling']} agents/day, elastic · typical wave "
    f"{m['wave_min']}–{m['wave_max']} · {m['swarm_peak_hour']} in flight at peak hour |",
    f"| **Fan-out** | {m['subagent_pct']:.0f}% of recent tokens spent by subagents; "
    f"{m['subagent_pct_intact']:.0f}% across the months whose transcripts survived. |",
    f"| **Provider diversity** | {m['models']} models, {m['vendors']} labs — though one carries "
    f"{m['top_vendor_pct']:.0f}% of spend. |",
    f"| **Cost discipline** | {m['cache_read_pct']:.0f}% of tokens are cache reads, at a tenth "
    "of input price. |",
    f"| **Accounting** | {100-m['unpriced_pct']-m['estimated_pct']:.0f}% priced from a published "
    f"card, {m['estimated_pct']:.1f}% estimated, {m['unpriced_pct']:.1f}% unpriced — at the rate "
    "in force *when spent*. |",
])

p = pathlib.Path("README.md"); t = p.read_text()
for a, b, blk in (("<!-- BEGIN LIVE-SUMMARY -->", "<!-- END LIVE-SUMMARY -->", body),
                  ("<!-- BEGIN LIVE-TABLE -->", "<!-- END LIVE-TABLE -->", table)):
    i, j = t.index(a), t.index(b)
    t = t[:i] + a + "\n" + blk + "\n" + t[j:]
p.write_text(t)
print("live blocks regenerated")
PY

# Cache-bust the badge images. Two independent caches sit between the JSON in
# this repo and what a visitor sees: shields.io caches the endpoint response,
# and GitHub's camo proxy caches the rendered PNG -- camo being the sticky one,
# which is why the profile showed 101.4B while this repo already said 102.8B.
# cacheSeconds asks shields to expire quickly; the rotating &v= stamp changes
# the image URL each refresh, so camo treats it as a new asset instead of
# serving its copy. Without the stamp, a shorter interval only makes the JSON
# fresher while the visible badge stays stale.
STAMP=$(date -u +%Y%m%d%H%M)
python3 - "$STAMP" <<'BUST'
import pathlib, re, sys
stamp = sys.argv[1]
p = pathlib.Path("README.md"); t = p.read_text()
t = re.sub(r'(img\.shields\.io/endpoint\?url=[^)\s]*?)(&cacheSeconds=\d+)?(&v=\d+)?\)',
           lambda m: f"{m.group(1)}&cacheSeconds=300&v={stamp})", t)
p.write_text(t)
BUST

git add badges usage.svg README.md
# Nothing changed is the common case on a quiet hour — not an error.
if git diff --cached --quiet; then
  echo "profile: no change"
  exit 0
fi
git commit -qm "profile: refresh telemetry $(date -u +%Y-%m-%dT%H:%MZ)"
# Push as the repo's OWNER, explicitly.
#
# The osxkeychain helper serves whichever GitHub account is ambiently ACTIVE, so
# a `gh auth switch` anywhere on this machine silently redirects this push. On
# 2026-08-14 the job began pushing as justakeyboardbetweenus (switched for an
# unrelated private-repo push) and every run afterwards died with
# `403 Permission to cmc-veup/cmc-veup.git denied`, exiting 124. Badges froze for
# an hour and nothing surfaced it: launchd records the exit code and no human
# reads it.
#
# A scheduled job must not depend on ambient interactive state. Resolve a token
# for the OWNING account out of gh's own store and push with that, so the job
# stays correct no matter who is "active".
_OWNER="${PROFILE_OWNER:-cmc-veup}"
_TOKEN=$([ -n "$GH" ] && "$GH" auth token -u "$_OWNER" -h github.com 2>/dev/null || true)
if [ -n "$_TOKEN" ]; then
  # Token in the URL rather than a stored remote: nothing is written to
  # .git/config, so the credential never persists on disk.
  git push -q "https://x-access-token:${_TOKEN}@github.com/${_OWNER}/${_OWNER}.git" main
else
  echo "profile: no gh token for $_OWNER (gh resolved: ${GH:-NONE}) — falling back to ambient auth" >&2
  git push -q origin main
fi
echo "profile: published $(git rev-parse --short HEAD)"
