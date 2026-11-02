#!/usr/bin/env bash
# =============================================================================
# missing-keys.sh - List the empty values of <lang>.json, with their French
# and English references, as a JSON array ready to be translated
#
# Usage:
#   bash tools/i18n.sh missing <lang-code> > todo.json
#
# Requirements: jq
# =============================================================================

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <language-code>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANG_DIR="$SCRIPT_DIR/../.."
FILE_NAME="$LANG_DIR/$1.json"

if [ ! -f "$FILE_NAME" ]; then
    echo "File $FILE_NAME does not exist."
    exit 1
fi

jq --slurpfile fr "$LANG_DIR/fr.json" --slurpfile en "$LANG_DIR/en.json" '
    . as $target
    | [paths(scalars) as $p | select($target | getpath($p) == "")
    | {path: $p, fr: ($fr[0] | getpath($p)), en: ($en[0] | getpath($p)), value: ""}]
' "$FILE_NAME"
