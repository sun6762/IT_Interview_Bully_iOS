#!/bin/sh

set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_DIR="$ROOT_DIR/.git/hooks"

if [ ! -d "$HOOK_DIR" ]; then
  echo "warning: .git/hooks not found. Initialize git repository first."
  exit 0
fi

cat > "$HOOK_DIR/pre-commit" <<'EOF'
#!/bin/sh
set -eu

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

./scripts/local_quality_gate.sh
EOF

chmod +x "$HOOK_DIR/pre-commit"
echo "info: installed pre-commit hook -> .git/hooks/pre-commit"

