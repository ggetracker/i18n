#!/usr/bin/env bash
# =============================================================================
# init-language.sh - Bootstrap a new translation file from GGE game data
#
# Creates <lang>.json in the project root by:
#   1. Copying fr.json as a blank template (all string values emptied).
#   2. Filling every value the game already translates (fill-from-game.sh).
#
# Keys the game does not cover are left empty: list them with
# 'bash tools/i18n.sh missing <lang>' and merge them back once translated.
#
# Usage:
#   bash tools/i18n.sh init <lang-code> [gge-lang-code]
#
# Arguments:
#   lang-code       Code of the file to create (e.g. ru, cs, hu)
#   gge-lang-code   Code GGE uses for that language, when it differs
#
# Requirements: curl, jq
# =============================================================================

set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <language-code> [gge-language-code]"
    exit 1
fi

LANG_CODE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANG_DIR="$SCRIPT_DIR/../.."
FILE_NAME="$LANG_DIR/${LANG_CODE}.json"

. "$SCRIPT_DIR/../lib/colors.sh"

if [ -f "$FILE_NAME" ]; then
    echo "File $FILE_NAME already exists."
    exit 1
fi

echo -e "${green_color}Creating template...${reset_color}"
jq 'walk(if type == "string" then "" else . end)' "$LANG_DIR/fr.json" > "$FILE_NAME"

"$SCRIPT_DIR/fill-from-game.sh" "$@"

echo
echo -e "${green_color}Finished:${reset_color} $FILE_NAME"
