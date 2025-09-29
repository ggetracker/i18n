#!/bin/bash

set -e

# This script checks the integrity and validity of translation JSON files
# in the current directory against a reference file (fr.json)
# It ensures that all translation files have the same keys as the reference
# and that they are valid JSON.
#
# Before committing changes to translation files, please run this script to verify their correctness
# Usage: ./check.sh


cd "$(dirname "$0")" || exit 1

# Load dependencies
source ./colors.sh
source ./utils.sh

cd .. || exit 1

readonly source_file="fr.json"

if [ ! -f "$source_file" ]; then
  echo -e "${red_color} Error: The file '$source_file' is missing.${reset_color}"
  exit 1
fi

errors=0

main() {
  print_header # Display header (in utils.sh)
  cd "$translations_dir" || exit 1
  ref_keys=$(extract_keys "$source_file")
  echo -e " Reference file: $source_file with $(echo "$ref_keys" | wc -l) keys."
  check_translations
  print_summary
}

check_translations() {
  for file in *.json; do
    [ "$file" = "$source_file" ] && continue
    echo -e "$yellow_color Checking file: $file...$reset_color"
    if [ ! -f "$file" ]; then
      echo -e " Error: $file does not exist."
      errors=$((errors + 1))
      continue
    fi
    if ! jq empty "$file" 2>/dev/null; then
      echo -e " Error: $file is not a valid JSON."
      errors=$((errors + 1))
      continue
    fi
    file_keys=$(extract_keys "$file")
    diff=$(diff -u <(echo "$ref_keys") <(echo "$file_keys") || true)
    if [ -n "$diff" ]; then
      echo -e " $yellow_color |- $red_color Error: differences detected in $file:$reset_color"
      echo "$diff"
      errors=$((errors + 1))
    else
      echo -e " $yellow_color |- $green_color Success: $file is valid and matches the reference structure.$reset_color"
    fi
  done
}

print_summary() {
  if [ $errors -eq 0 ]; then
    echo -e "\n${green_color} All translation files are valid and match the reference structure.${reset_color}"
    exit 0
  else
    echo -e "\n${red_color} Completed with $errors error(s). Please review the above messages.${reset_color}"
    exit 1
  fi
}

main
