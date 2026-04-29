#!/usr/bin/env bash
# test_all.sh — run every test suite and aggregate the result.
# Run: bash tests/test_all.sh
#
# Exit code is 0 if all suites pass, non-zero if any suite fails.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_DIR="$REPO_ROOT/tests"

SUITES=(
    "test_structure.sh"
    "test_skill.sh"
    "test_brief.sh"
    "test_draft.sh"
    "test_render.sh"
    "test_install.sh"
)

PASSED=()
FAILED=()

for suite in "${SUITES[@]}"; do
    path="$TESTS_DIR/$suite"
    if [ ! -f "$path" ]; then
        echo "  ✗ $suite — missing"
        FAILED+=("$suite")
        continue
    fi
    echo ""
    echo "########## $suite ##########"
    if bash "$path"; then
        PASSED+=("$suite")
    else
        FAILED+=("$suite")
    fi
done

echo ""
echo "============================================="
echo "Aggregate: ${#PASSED[@]} suite(s) passed, ${#FAILED[@]} failed"

if [ ${#FAILED[@]} -gt 0 ]; then
    echo "Failed suites:"
    for s in "${FAILED[@]}"; do echo "  - $s"; done
    exit 1
fi
