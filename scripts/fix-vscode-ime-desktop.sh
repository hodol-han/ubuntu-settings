#!/bin/bash

# This script adds "--ozone-platform=x11" to the Exec lines in the VS Code
# desktop files: code.desktop and code-url-handler.desktop in /usr/share/applications/.
# A backup (.bak) of each file is created before modification.

set -euo pipefail

OPTION="--ozone-platform=x11"
FILES=(
  "/usr/share/applications/code.desktop"
  "/usr/share/applications/code-url-handler.desktop"
)

if [ "$(id -u)" != '0' ]; then
  # Restart script as postgres user when run as root.
  echo "$(basename "$0") requires to be run as root. Entering root..."
  exec sudo -- "${BASH_SOURCE[0]}" "$@"
fi

TEMP_FILES=()
for FILE in "${FILES[@]}"; do
  if [[ -f "$FILE" ]] && grep -q '^Exec=.*--ozone-platform=x11' "$FILE"; then
    echo "$FILE already contains --ozone-platform=x11. Skipping update."
  else
    TEMP_FILES+=("$FILE")
  fi
done

FILES=("${TEMP_FILES[@]}")

for FILE in "${FILES[@]}"; do
  if [[ -f "$FILE" ]]; then
    echo "Updating $FILE..."
    # Backup the original file
    sudo cp "$FILE" "$FILE.bak"
    # Append the OPTION to the first word following "Exec=" if not already present.
    sudo sed -i -E "/^Exec=/ {
            /${OPTION}/! s/(^Exec=[^[:space:]]+)/\1 ${OPTION}/
        }" "$FILE"
  else
    echo "File $FILE not found."
  fi
done

echo "Update complete."
