#!/bin/sh

set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "info: running heuristic performance guard..."

HIT=0

check_pattern() {
  PATTERN="$1"
  MESSAGE="$2"
  if rg -n "$PATTERN" IT_Interview_Bully IT_Interview_BullyTests >/dev/null 2>&1; then
    echo "warning: $MESSAGE"
    rg -n "$PATTERN" IT_Interview_Bully IT_Interview_BullyTests || true
    HIT=1
  fi
}

check_pattern 'NotificationCenter\.default\.addObserver' "Observer registration found. Verify removal path."
check_pattern 'Timer\.scheduledTimer' "Scheduled timer found. Verify invalidation and capture strategy."
check_pattern 'CADisplayLink' "DisplayLink found. Verify invalidation path."
check_pattern 'masksToBounds\s*=\s*true' "masksToBounds=true found. Check offscreen rendering impact."
check_pattern 'shouldRasterize\s*=\s*true' "shouldRasterize=true found. Ensure rasterizationScale is set."
check_pattern 'UIGraphicsBeginImageContext' "Legacy image context found. Prefer UIGraphicsImageRenderer."

if [ "$HIT" -eq 0 ]; then
  echo "info: no high-risk heuristic patterns found."
else
  echo "info: review warnings above. This is a heuristic check, not a blocker."
fi

