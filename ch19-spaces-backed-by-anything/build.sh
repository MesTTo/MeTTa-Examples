#!/bin/sh
# Purpose: compile every C example in this chapter, so the examples gate
#   exercises the C tier for real rather than taking its skip branches.
# Guarantees:
#   - each object is published by rename through tools/link.sh, so a test
#     loading cstore.so while the gate rebuilds it opens a whole object
#     [tested 2026-09-26T17:51:21+10:00: tests/shell/test_builds_publish_by_rename.sh].
#     The name carries its .so, which swipl-ld keeps as written: it adds an
#     extension only to a bare name [measured 2026-09-26T17:51:25+10:00: -o
#     stage.tmp wrote stage.tmp, -o plainname wrote plainname.so].
#   - every .c under a chapter section is built, rather than a list of unit
#     names. cstore.so was COMMITTED for as long as nothing here built it,
#     which put one machine's compiled object in the repository and gave the
#     C-space example a binary its own README tells you to compile. A fourth
#     example needs no edit here.
#   - no swipl-ld exits 0 with a note: these examples skip, which is what the
#     runner already does with them.
# Open Obligations:
#   To Do: None
#   Hacks: None
#   Future Enhancements: None

set -eu

HERE=$(cd -- "$(dirname -- "$0")" && pwd)

if ! command -v swipl-ld >/dev/null 2>&1; then
    echo "ch19/build.sh: swipl-ld not found; the chapter's C examples will skip" >&2
    exit 0
fi

# One spelling of the bound, implemented in bounded.sh, which every runner in
# this tree and a command typed by hand all reach.
bounded() { sh "$HERE/../../tools/bounded.sh" "$@"; }

status=0
for source in "$HERE"/*/*.c; do
    [ -f "$source" ] || continue
    directory=$(dirname "$source")
    unit=$(basename "$source" .c)
    if ! ( cd "$directory" && bounded sh "$HERE/../../tools/link.sh" "$unit.so" -shared "$unit.c" ); then
        echo "ch19/build.sh: the C example $unit failed to build" >&2
        status=1
    fi
done
exit "$status"
