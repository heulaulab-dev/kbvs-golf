#!/usr/bin/env bash
# Verify that the test count declared in README.md / CHANGELOG.md matches reality.
#
# Marker convention:
#   A doc is considered to declare a count if it contains a line like:
#       <!-- test-count: N -->
#   where N is an integer. The script collects all declared counts across
#   README.md and CHANGELOG.md and asserts:
#     1. At least one declaration exists
#     2. All declarations agree
#     3. The declared count matches the actual `flutter test` pass count
#
# Exit codes:
#   0 = pass
#   1 = count mismatch or parse failure
#   2 = flutter test itself failed (caller should already have noticed)
#
# "Loud, not silent": on failure, prints every declared count, the actual
# count, and the exact command to update docs.

set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# 1. Find declared counts.
declare -a DECLARED_SOURCES=()
declare -a DECLARED_COUNTS=()

while IFS=: read -r file line content; do
    count=$(echo "$content" | sed -n 's/.*<!-- *test-count: *\([0-9][0-9]*\) *-->.*/\1/p')
    if [[ -n "$count" ]]; then
        DECLARED_SOURCES+=("$file:$line")
        DECLARED_COUNTS+=("$count")
    fi
done < <(grep -nE 'test-count: *[0-9]+' README.md CHANGELOG.md 2>/dev/null)

if [[ ${#DECLARED_COUNTS[@]} -eq 0 ]]; then
    echo "❌ FAIL: no '<!-- test-count: N -->' marker found in README.md or CHANGELOG.md"
    echo "   Add one, e.g.: <!-- test-count: 72 -->"
    exit 1
fi

# 2. Check declared counts agree.
UNIQUE_DECLARED=$(printf '%s\n' "${DECLARED_COUNTS[@]}" | sort -u)
UNIQUE_COUNT=$(echo "$UNIQUE_DECLARED" | wc -l)
if [[ "$UNIQUE_COUNT" -gt 1 ]]; then
    echo "❌ FAIL: docs disagree on test count"
    for i in "${!DECLARED_SOURCES[@]}"; do
        echo "   ${DECLARED_SOURCES[$i]}: ${DECLARED_COUNTS[$i]}"
    done
    exit 1
fi
DOC_COUNT="$UNIQUE_DECLARED"

# 3. Run flutter test and parse pass count.
echo "▶ Running flutter test..."
TEST_OUTPUT=$(flutter test --reporter=expanded 2>&1)
TEST_EXIT=$?

if [[ $TEST_EXIT -ne 0 ]]; then
    echo "❌ FAIL: flutter test exited $TEST_EXIT — fix the failures before checking counts"
    echo "$TEST_OUTPUT" | tail -30
    exit 2
fi

# Parse the final "+N: All tests passed!" line. Tolerate either "+N -M:" or "+N:" prefix.
ACTUAL=$(echo "$TEST_OUTPUT" | grep -oE '\+[0-9]+: All tests passed' | tail -1 | grep -oE '[0-9]+')
if [[ -z "$ACTUAL" ]]; then
    # Fallback: some reporters print "+N: Some tests failed." — try the highest +N seen.
    ACTUAL=$(echo "$TEST_OUTPUT" | grep -oE '\+[0-9]+' | tail -1 | tr -d '+')
fi
if [[ -z "$ACTUAL" ]]; then
    echo "❌ FAIL: could not parse pass count from flutter test output"
    echo "--- output ---"
    echo "$TEST_OUTPUT" | tail -20
    echo "--- /output ---"
    exit 1
fi

# 4. Compare.
echo ""
echo "   docs declare: $DOC_COUNT"
echo "   tests report: $ACTUAL"

if [[ "$DOC_COUNT" != "$ACTUAL" ]]; then
    echo ""
    echo "❌ FAIL: test count drift detected"
    echo ""
    echo "Fix by updating the marker to: <!-- test-count: $ACTUAL -->"
    echo "Files containing the marker:"
    for src in "${DECLARED_SOURCES[@]}"; do
        echo "   $src"
    done
    exit 1
fi

echo ""
echo "✅ PASS: test count $ACTUAL matches docs"
