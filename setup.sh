#!/usr/bin/env bash
# setup.sh — Symlink xenia-upstream's src/ and third_party/ into the repo root
# so CMake can find them at the paths it expects (XENIA_ROOT/src and
# XENIA_ROOT/third_party).
#
# Run once after:
#   git submodule update --init --recursive --depth 1
#
# Safe to re-run; existing correct symlinks are left untouched.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM="${SCRIPT_DIR}/xenia-upstream"

# --- Guard: submodule must be present ---
if [[ ! -d "${UPSTREAM}/src" ]]; then
  echo "ERROR: xenia-upstream submodule is not initialised." >&2
  echo "Run: git submodule update --init --depth 1 xenia-upstream" >&2
  exit 1
fi

echo "Setting up symlinks from xenia-upstream..."

for target in src third_party; do
  src_path="${UPSTREAM}/${target}"
  link_path="${SCRIPT_DIR}/${target}"

  if [[ ! -d "${src_path}" ]]; then
    echo "  WARNING: ${UPSTREAM}/${target} does not exist — skipping"
    continue
  fi

  if [[ -L "${link_path}" ]]; then
    current_target="$(readlink "${link_path}")"
    if [[ "${current_target}" == "${src_path}" ]]; then
      echo "  OK (already linked): ${target} -> xenia-upstream/${target}"
    else
      echo "  Updating symlink: ${target} -> xenia-upstream/${target}"
      ln -sf "${src_path}" "${link_path}"
    fi
  elif [[ -e "${link_path}" ]]; then
    echo "  WARNING: ${link_path} exists as a real file/directory; skipping." >&2
    echo "           Delete or rename it and re-run setup.sh to create the symlink." >&2
  else
    ln -s "${src_path}" "${link_path}"
    echo "  Created: ${target} -> xenia-upstream/${target}"
  fi
done

echo ""
echo "Setup complete. Build with:"
echo "  ./gradlew assembleDebug"
