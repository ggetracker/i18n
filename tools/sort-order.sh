#!/bin/bash

# This script sorts the keys of translation JSON files
# in the current directory in alphabetical order.
# Usage: ./sort-order.sh file1.json file2.json ...

set -e

if ! command -v jq &> /dev/null; then
  echo "jq is required but not installed. Please install jq and try again."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit 1
FILES=$(find . -maxdepth 1 -type f -name "*.json")

for file in $FILES; do
  tmp="$(mktemp)"
  jq -S '.' "$file" > "$tmp" && mv "$tmp" "$file"
  echo "Sorted keys in $file"
done