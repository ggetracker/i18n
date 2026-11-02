#!/usr/bin/env bash
# =============================================================================
# merge-translations.sh - Write translated entries back into <lang>.json
#
# Usage:
#   bash tools/i18n.sh merge <lang-code> <translations.json>
#
# Requirements: jq
# =============================================================================

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <language-code> <translations.json>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANG_DIR="$SCRIPT_DIR/../.."
FILE_NAME="$LANG_DIR/$1.json"

. "$SCRIPT_DIR/../lib/colors.sh"

if [ ! -f "$FILE_NAME" ]; then
    echo "File $FILE_NAME does not exist."
    exit 1
fi

unknown="$(jq -r --slurpfile fr "$LANG_DIR/fr.json" '
    .[] | select(.path as $p | ($fr[0] | getpath($p)) | type != "string") | .path | tostring
' "$2")"

if [ -n "$unknown" ]; then
    echo -e "${red_color}Paths not declared in fr.json:${reset_color}"
    echo "$unknown"
    exit 1
fi

tmp="$(mktemp)"
jq --slurpfile entries "$2" '
    reduce ($entries[0][] | select((.value // "") != "")) as $e (.; setpath($e.path; $e.value))
' "$FILE_NAME" > "$tmp"
mv "$tmp" "$FILE_NAME"

echo -e "${green_color}Merged:${reset_color} $(jq '[.[] | select((.value // "") != "")] | length' "$2") entries into $(basename "$FILE_NAME")"
