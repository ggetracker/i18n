#!/usr/bin/env bash
# =============================================================================
# fill-from-game.sh - Fill the empty values of <lang>.json with GGE strings
#
# Usage:
#   bash tools/bin/fill-from-game.sh <lang-code> [gge-lang-code]
#   bash tools/i18n.sh fill <lang-code> [gge-lang-code]
#
# Requirements: curl, jq
# =============================================================================

set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <language-code> [gge-language-code]"
    exit 1
fi

LANG_CODE="$1"
GGE_LANG_CODE="${2:-$1}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANG_DIR="$SCRIPT_DIR/../.."
CONF_FILE="$SCRIPT_DIR/../data/ingame-keys.conf"
FILE_NAME="$LANG_DIR/${LANG_CODE}.json"

. "$SCRIPT_DIR/../lib/gge-api.sh"
. "$SCRIPT_DIR/../lib/colors.sh"

if [ ! -f "$FILE_NAME" ]; then
    echo "File $FILE_NAME does not exist. Run 'bash tools/i18n.sh init $LANG_CODE' first."
    exit 1
fi

BASE_URL="https://empire-html5.goodgamestudios.com/config/languages/$GGE_XML_VERSION"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

echo -e "${green_color}Using GGE XML version: $GGE_XML_VERSION${reset_color}"

for code in fr en "$GGE_LANG_CODE"; do
    curl -sf "$BASE_URL/$code.json" -o "$WORK_DIR/gge-$code.json" || {
        echo "Could not fetch $code.json from GGE"
        exit 1
    }
done

grep -v '^\s*#' "$CONF_FILE" | grep '=' \
    | jq -R 'capture("^(?<local>.*)=(?<gge>[^=]*)$")' \
    | jq -s 'map({(.local): .gge}) | add // {}' > "$WORK_DIR/conf.json"

jq -n \
    --slurpfile target "$FILE_NAME" \
    --slurpfile localFr "$LANG_DIR/fr.json" \
    --slurpfile localEn "$LANG_DIR/en.json" \
    --slurpfile ggeFr "$WORK_DIR/gge-fr.json" \
    --slurpfile ggeEn "$WORK_DIR/gge-en.json" \
    --slurpfile ggeTarget "$WORK_DIR/gge-$GGE_LANG_CODE.json" \
    --slurpfile conf "$WORK_DIR/conf.json" '
    def placeholders: map_values(tostring | gsub("(?<!\\{)\\{(?<n>[0-9]+)\\}(?!\\})"; "{{\(.n)}}"));
    ($ggeFr[0] | placeholders) as $F | ($ggeEn[0] | placeholders) as $E | ($ggeTarget[0] | placeholders) as $T | ($conf[0]) as $C |
    (reduce ($F | keys_unsorted[]) as $k ({};
        ($F[$k] | tostring) as $v | if ($v | length) > 0 then .[$v] += [$k] else . end)) as $byFrench |
    def translated($k): ($T[$k] // "") | tostring;
    def fromConf($path): ($C[$path | join(".")] // null) as $k
        | if $k != null and (translated($k) | length) > 0 then translated($k) else null end;
    def fromMatch($path): ($localFr[0] | getpath($path)) as $fr | ($localEn[0] | getpath($path)) as $en
        | [($byFrench[$fr] // [])[] | select($E[.] == $en) | translated(.) | select(length > 0)]
        | if length > 0 then group_by(.) | max_by(length) | .[0] else null end;
    reduce ($target[0] | paths(scalars) | select(. as $p | $target[0] | getpath($p) == "")) as $path
        ({file: $target[0], conf: 0, matched: 0, left: 0};
        (fromConf($path)) as $c |
        if $c != null then .file |= setpath($path; $c) | .conf += 1
        else (fromMatch($path)) as $m |
            if $m != null then .file |= setpath($path; $m) | .matched += 1
            else .left += 1 end
        end)
' > "$WORK_DIR/result.json"

jq '.file' "$WORK_DIR/result.json" > "$FILE_NAME"

echo -e "${green_color}From ingame-keys.conf:${reset_color} $(jq '.conf' "$WORK_DIR/result.json")"
echo -e "${green_color}Matched on the French and English strings:${reset_color} $(jq '.matched' "$WORK_DIR/result.json")"
echo -e "${yellow_color}Still empty:${reset_color} $(jq '.left' "$WORK_DIR/result.json") (list them with 'bash tools/i18n.sh missing $LANG_CODE')"
