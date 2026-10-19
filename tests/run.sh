#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Keep Godot's writable editor settings/logs inside the sandbox, and never overlap processes.
export XDG_CONFIG_HOME="${TMPDIR:-/tmp}/thief-of-dawn-test-config"
export XDG_DATA_HOME="${TMPDIR:-/tmp}/thief-of-dawn-test-data"
logs=$(mktemp -d "${TMPDIR:-/tmp}/thief-tests.XXXXXX")
trap 'rm -rf "$logs"' EXIT
run_check() {
    local marker=$1
    shift
    if ! timeout 120s godot "$@" >"$logs/check.log" 2>&1; then
        cat "$logs/check.log"
        return 1
    fi
    if grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error' "$logs/check.log"; then
        cat "$logs/check.log"
        return 1
    fi
    if [[ -n "$marker" ]]; then
        if ! grep -E "^$marker" "$logs/check.log"; then
            cat "$logs/check.log"
            return 1
        fi
    fi
}
run_check '' --headless --path . --import
printf 'IMPORT OK\n'
for level in levels/level*.txt; do
    number=${level##*/level}
    number=${number%.txt}
    run_check 'SMOKE OK' --headless --fixed-fps 60 --path . -- --level="$number" --smoke=1800
done
for route in tests/routes/*.seq; do
    number=${route##*/level}
    number=${number%.seq}
    run_check 'ROUTE OK' --headless --fixed-fps 60 --path . -- --level="$number" --route="$route"
done
run_check 'MECHANICS OK' --headless --fixed-fps 60 --path . tests/mechanics.tscn
printf 'ALL TESTS OK\n'
