#!/bin/sh

set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if command -v swiftlint >/dev/null 2>&1; then
  swiftlint --config "$ROOT_DIR/.swiftlint.yml"
else
  echo "warning: SwiftLint is not installed. Install it with 'brew install swiftlint' to enable lint checks."
fi
