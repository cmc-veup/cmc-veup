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
python3 -m flightdeck.cli badges --out "$PROFILE" --rank "$RANK" --rank-total "${VIBERANK_TOTAL:-1000}" --days 30 >/dev/null

cd "$PROFILE"
git add badges usage.svg
# Nothing changed is the common case on a quiet hour — not an error.
if git diff --cached --quiet; then
  echo "profile: no change"
  exit 0
fi
git commit -qm "profile: refresh telemetry $(date -u +%Y-%m-%dT%H:%MZ)"
git push -q origin main
echo "profile: published $(git rev-parse --short HEAD)"
