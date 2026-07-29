#!/usr/bin/env bash
# Install the test-count-guard pre-commit hook.
#
# Run once after cloning:    bash tool/setup-pre-commit.sh
# To bypass on a given commit:  git commit --no-verify

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK_SRC="$REPO_ROOT/tool/pre-commit"
HOOK_DST="$REPO_ROOT/.git/hooks/pre-commit"

if [[ ! -d "$REPO_ROOT/.git" ]]; then
    echo "❌ Not a git repo: $REPO_ROOT"
    exit 1
fi

cp "$HOOK_SRC" "$HOOK_DST"
chmod +x "$HOOK_DST"

echo "✅ Installed pre-commit hook at $HOOK_DST"
echo "   Runs tool/verify_test_count.sh before every commit."
echo "   Bypass with: git commit --no-verify"
