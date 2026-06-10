#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies install.sh contracts (multi-assistant model).
# Run: bash tests/test_install.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"
README="$REPO_ROOT/README.md"
PASS=0
FAIL=0

assert_grep()   { if grep -qE  -e "$2" "$1"; then echo "  PASS: $3"; PASS=$((PASS+1)); else echo "  FAIL: $3 — no match: $2"; FAIL=$((FAIL+1)); fi; }
assert_grep_i() { if grep -qiE -e "$2" "$1"; then echo "  PASS: $3"; PASS=$((PASS+1)); else echo "  FAIL: $3 — no match: $2"; FAIL=$((FAIL+1)); fi; }
assert_file()   { if [ -f "$1" ]; then echo "  PASS: $2"; PASS=$((PASS+1)); else echo "  FAIL: $2 — missing $1"; FAIL=$((FAIL+1)); fi; }
assert_dir()    { if [ -d "$1" ]; then echo "  PASS: $2"; PASS=$((PASS+1)); else echo "  FAIL: $2 — missing $1"; FAIL=$((FAIL+1)); fi; }
assert_nofile() { if [ ! -e "$1" ]; then echo "  PASS: $2"; PASS=$((PASS+1)); else echo "  FAIL: $2 — exists $1"; FAIL=$((FAIL+1)); fi; }

# Run with expected exit + a needle in output. FORCE skips the dep prompt.
assert_run() {  # <expected_exit> <needle> <label> -- <args...>
    local exp="$1" needle="$2" label="$3"; shift 3; [ "$1" = "--" ] && shift
    local out rc=0
    out="$(bash "$INSTALL_SH" "$@" 2>&1)" || rc=$?
    if [ "$rc" -eq "$exp" ] && printf '%s' "$out" | grep -qF "$needle"; then
        echo "  PASS: $label"; PASS=$((PASS+1))
    else
        echo "  FAIL: $label — exit=$rc (want $exp); output:"; printf '%s\n' "$out" | head -4; FAIL=$((FAIL+1))
    fi
}

fake_home() { mktemp -d; }
cleanup() { rm -rf "$1"; }

echo "=== Static contract checks ==="
assert_grep "$INSTALL_SH" '#!/usr/bin/env bash' "shebang"
assert_grep "$INSTALL_SH" 'set -euo pipefail' "strict bash mode"
assert_grep "$INSTALL_SH" '\-\-target' "supports --target"
assert_grep "$INSTALL_SH" '\-\-force' "supports --force"
assert_grep "$INSTALL_SH" '\-\-check' "supports --check"
assert_grep "$INSTALL_SH" '\.claude/skills/deck' "claude dest"
assert_grep "$INSTALL_SH" '\.codex/skills/deck' "codex dest"
assert_grep "$INSTALL_SH" 'opencode/skills/deck' "opencode dest"
assert_grep "$INSTALL_SH" 'git clone' "remote install via git clone"
assert_grep_i "$INSTALL_SH" 'md2' "probes md2 dependency"
assert_grep_i "$INSTALL_SH" 'chromium|chrome|firefox' "probes browser dependency"
[ -x "$INSTALL_SH" ] && { echo "  PASS: install.sh executable"; PASS=$((PASS+1)); } || { echo "  FAIL: install.sh not +x"; FAIL=$((FAIL+1)); }
assert_run 0 "Usage" "--help exits cleanly" -- --help

echo "=== Verbatim targets (claude/codex/opencode) ==="
for t in claude codex opencode; do
    H="$(fake_home)"
    case "$t" in
        claude)   D="$H/.claude/skills/deck" ;;
        codex)    D="$H/.codex/skills/deck" ;;
        opencode) D="$H/.config/opencode/skills/deck" ;;
    esac
    echo "--- $t ---"
    HOME="$H" bash "$INSTALL_SH" --force --target "$t" >/dev/null 2>&1
    assert_file "$D/SKILL.md" "$t: SKILL.md installed"
    assert_file "$D/render/render.sh" "$t: render.sh installed"
    [ -x "$D/render/render.sh" ] && { echo "  PASS: $t: render.sh executable"; PASS=$((PASS+1)); } || { echo "  FAIL: $t: render.sh not +x"; FAIL=$((FAIL+1)); }
    HOME="$H" assert_run 0 "OK" "$t: --check clean" -- --check --target "$t"
    echo "edit" >> "$D/SKILL.md"
    HOME="$H" assert_run 1 "DRIFT" "$t: --check detects drift" -- --check --target "$t"
    cleanup "$H"
done

echo "=== Default + back-compat ==="
H="$(fake_home)"
HOME="$H" bash "$INSTALL_SH" --force >/dev/null 2>&1
assert_dir "$H/.claude/skills/deck" "default (non-interactive) installs claude"
cleanup "$H"
H="$(fake_home)"
HOME="$H" bash "$INSTALL_SH" --force claude >/dev/null 2>&1
assert_dir "$H/.claude/skills/deck" "bare 'claude' word still works"
cleanup "$H"

echo "=== --check on missing install ==="
H="$(fake_home)"
HOME="$H" assert_run 1 "DRIFT" "missing install reported as drift" -- --check --target claude
cleanup "$H"

echo "=== Gemini TOML wrapper ==="
H="$(fake_home)"
HOME="$H" bash "$INSTALL_SH" --force --target gemini >/dev/null 2>&1
assert_file "$H/.gemini/commands/deck.toml" "gemini: toml written"
assert_file "$H/.config/deck/SKILL.md" "gemini: payload in neutral home"
if grep -q 'prompt' "$H/.gemini/commands/deck.toml" && grep -q 'SKILL.md' "$H/.gemini/commands/deck.toml"; then
    echo "  PASS: gemini: toml references the router"; PASS=$((PASS+1))
else echo "  FAIL: gemini: toml missing prompt/SKILL.md"; FAIL=$((FAIL+1)); fi
cleanup "$H"

echo "=== AGENTS.md pointer (idempotent) ==="
H="$(fake_home)"; PROJ="$(mktemp -d)"
HOME="$H" bash "$INSTALL_SH" --force --target agents --agents-dir "$PROJ" >/dev/null 2>&1
assert_file "$PROJ/AGENTS.md" "agents: AGENTS.md written"
HOME="$H" bash "$INSTALL_SH" --force --target agents --agents-dir "$PROJ" >/dev/null 2>&1
n="$(grep -cF 'deck:start' "$PROJ/AGENTS.md")"
[ "$n" -eq 1 ] && { echo "  PASS: agents: pointer not duplicated"; PASS=$((PASS+1)); } || { echo "  FAIL: agents: duplicated ($n)"; FAIL=$((FAIL+1)); }
cleanup "$H"; cleanup "$PROJ"

echo "=== Manual (prints path, writes nothing) ==="
H="$(fake_home)"
HOME="$H" assert_run 0 "deck" "manual prints payload path" -- --target manual
assert_nofile "$H/.claude" "manual wrote nothing under HOME"
cleanup "$H"

echo "=== README Requirements ==="
assert_grep_i "$README" '^##.*[Rr]equirements' "has Requirements section"
assert_grep_i "$README" 'md2' "Requirements mentions md2"
assert_grep_i "$README" 'chromium|google-chrome|chrome|firefox' "Requirements mentions browser"
assert_grep "$README" '/deck brief'  "documents /deck brief"
assert_grep "$README" '/deck draft'  "documents /deck draft"
assert_grep "$README" '/deck render' "documents /deck render"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
