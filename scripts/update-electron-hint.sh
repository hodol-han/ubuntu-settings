#!/usr/bin/env bash

usage() {
  cat << EOF >&2
-----------------------------------------------------------------------------
update-electron-hint.sh

Ensures that the given file contains:
  export ELECTRON_OZONE_PLATFORM_HINT=<VALUE>
If the line exists, its value is replaced; otherwise, the line is appended.

Usage:
  ./update-electron-hint.sh <target_file> [value]
Examples:
  ./update-electron-hint.sh ~/.bashrc
  ./update-electron-hint.sh ~/.profile wayland

-----------------------------------------------------------------------------
EOF
}

validate_file() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    echo "Error: ${file} is not a file." >&2
    return 1
  fi

  if [[ ! -w "${file}" ]]; then
    echo "Error: ${file} is not writable." >&2
    return 1
  fi
}

set -euo pipefail

TARGET_FILE="${1:-.profile}"
VALUE="${2:-x11}"

test ! -z "$TARGET_FILE" || {
  usage
  exit 1
}
validate_file "$TARGET_FILE" || {
  usage
  exit 1
}

before="^export[[:space:]]+ELECTRON_OZONE_PLATFORM_HINT=.*"
after="export ELECTRON_OZONE_PLATFORM_HINT=${VALUE}"

# Look for an existing export line
if grep -qE "${before}" "${TARGET_FILE}"; then
  echo "Existing entry found. Updating value to '${VALUE}'..."

  sed --in-place=".$(date +%Y%m%d%H%M%S).bak" -E \
    "s|${before}|${after}|g" \
    "${TARGET_FILE}"
else
  echo "No existing entry found. Appending new line..."
  {
    echo "# Added by update-electron-hint.sh"
    echo "${after}"
  } >> "${TARGET_FILE}"
fi

echo "Done. ${TARGET_FILE} now contains ELECTRON_OZONE_PLATFORM_HINT=${VALUE}."
