#!/bin/bash

set -euo pipefail

REMOTE_KEY="$1"
LOCAL_KEY="$2"

GGE_CODE="4030"

BASE_URL="https://empire-html5.goodgamestudios.com/config/languages/$GGE_CODE"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANG_DIR="$SCRIPT_DIR/.."

for file in "$LANG_DIR"/*.json; do
  filename="$(basename "$file")"
  country="${filename%.json}"
  echo "Processing $country..."
  remote_json="$(curl -sf "$BASE_URL/$country.json")" || {
    echo "Error: Could not fetch $country.json from GGE, exiting." && exit 1
  }
  value="$(echo "$remote_json" | jq -er --arg key "$REMOTE_KEY" '.[$key]')" || {
    echo "Error: Key '$REMOTE_KEY' not found in GGE $country.json, exiting." && exit 1
  }
  tmp="$(mktemp)"

  jq --arg key "$LOCAL_KEY" --arg value "$value" '. + {($key): $value}' "$file" > "$tmp"
  mv "$tmp" "$file"
  echo "Updated $LOCAL_KEY in $filename with value from GGE $REMOTE_KEY."

done
