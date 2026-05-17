#!/bin/sh

set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_with_brew() {
  FORMULA="$1"
  if ! brew list "$FORMULA" >/dev/null 2>&1; then
    echo "info: installing $FORMULA ..."
    if ! brew install "$FORMULA"; then
      echo "error: failed to install $FORMULA via Homebrew."
      echo "hint: if you see 'unknown or unsupported macOS version', your Homebrew runtime is blocked by OS recognition."
      echo "hint: update Homebrew and Xcode CLT, or install on a stable supported macOS build."
      exit 1
    fi
  else
    echo "info: $FORMULA already installed."
  fi
}

if ! need_cmd brew; then
  echo "error: Homebrew is required. Install from https://brew.sh first."
  exit 1
fi

install_with_brew swiftlint
install_with_brew clang-format

echo "info: verifying toolchain..."
swiftlint version
clang-format --version

echo "info: running local quality gate..."
./scripts/local_quality_gate.sh

echo "info: bootstrap completed."
