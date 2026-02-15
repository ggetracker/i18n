#!/bin/bash

# This script sorts the keys of translation JSON files
# in the current directory in alphabetical order.
# Usage: ./sort-order.sh file1.json file2.json ...

set -e

if ! command -v jq &> /dev/null; then
  echo "jq is required but not installed. Please install jq and try again."
  exit 1
fi

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 file1.json file2.json, or *.json for all JSON files in the current directory."
  exit 1
fi

for file in "$@"; do
  tmp="$(mktemp)"
  jq -S '.' "$file" > "$tmp" && mv "$tmp" "$file"
done