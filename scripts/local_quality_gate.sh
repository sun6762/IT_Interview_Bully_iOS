#!/bin/sh

set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "info: [1/3] SwiftLint"
./scripts/swiftlint.sh

echo "info: [2/3] Objective-C lint"
./scripts/lint_objc.sh

echo "info: [3/3] Performance heuristic scan"
./scripts/performance_guard.sh

echo "info: local quality gate passed."

