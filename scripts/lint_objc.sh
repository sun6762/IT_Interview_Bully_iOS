#!/bin/sh

set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v clang-format >/dev/null 2>&1; then
  echo "warning: clang-format is not installed. Install with 'brew install clang-format'."
  exit 0
fi

OBJC_FILES="$(find IT_Interview_Bully IT_Interview_BullyTests -type f \( -name '*.h' -o -name '*.m' -o -name '*.mm' \) 2>/dev/null || true)"

if [ -z "$OBJC_FILES" ]; then
  echo "info: no Objective-C files found, skipping clang-format check."
  exit 0
fi

FAILED=0
for file in $OBJC_FILES; do
  if ! clang-format --dry-run --Werror "$file"; then
    echo "error: Objective-C format violation -> $file"
    FAILED=1
  fi
done

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi

echo "info: Objective-C format check passed."

