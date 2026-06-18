#!/usr/bin/env bash
# Clean build/cache directories for Dart, TS, Rust and other common tooling.
# Usage:
#   ./clean-builds.sh            # dry-run: shows what would be deleted and total size
#   ./clean-builds.sh --apply    # actually delete
#   ./clean-builds.sh --apply -y # delete without confirmation

set -euo pipefail

ROOT="${ROOT:-$(pwd)}"
APPLY=0
ASSUME_YES=0

for arg in "$@"; do
  case "$arg" in
    --apply)   APPLY=1 ;;
    -y|--yes)  ASSUME_YES=1 ;;
    -h|--help)
      sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

# Directory names to nuke. Matched by basename anywhere in the tree.
TARGETS=(
  # Dart / Flutter
  ".dart_tool"
  "build"
  ".flutter-plugins-dependencies"
  # Rust
  "target"
  # JS / TS
  "node_modules"
  "dist"
  "out"
  ".next"
  ".nuxt"
  ".turbo"
  ".parcel-cache"
  ".svelte-kit"
  ".cache"
  "coverage"
  ".nyc_output"
)

# Directories we never descend into while searching.
PRUNES=(".git" ".hg" ".svn")

# Build find expression as an array (bash 3.2 compatible).
FIND_ARGS=(-mindepth 1)

# Prune VCS dirs first.
FIND_ARGS+=(\()
first=1
for p in "${PRUNES[@]}"; do
  if [ $first -eq 1 ]; then first=0; else FIND_ARGS+=(-o); fi
  FIND_ARGS+=(-type d -name "$p")
done
FIND_ARGS+=(\) -prune -o)

# Match targets (also prune them so we don't descend — e.g. build/ inside node_modules/).
FIND_ARGS+=(\()
first=1
for t in "${TARGETS[@]}"; do
  if [ $first -eq 1 ]; then first=0; else FIND_ARGS+=(-o); fi
  FIND_ARGS+=(-name "$t")
done
FIND_ARGS+=(\) -type d -prune -print0)

echo "Scanning $ROOT ..."
# Collect matches into a NUL-separated list.
MATCHES_FILE="$(mktemp)"
trap 'rm -f "$MATCHES_FILE"' EXIT
find "$ROOT" "${FIND_ARGS[@]}" > "$MATCHES_FILE" 2>/dev/null || true

count=0
total_bytes=0

# macOS du reports 512-byte blocks with -s without -k; use -sk for KB.
while IFS= read -r -d '' dir; do
  size_kb=$(du -sk "$dir" 2>/dev/null | awk '{print $1}')
  size_kb=${size_kb:-0}
  total_bytes=$(( total_bytes + size_kb * 1024 ))
  count=$(( count + 1 ))
  # Human-readable per-entry size.
  hsize=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
  printf '%8s  %s\n' "${hsize:-?}" "$dir"
done < "$MATCHES_FILE"

# Human-readable total.
human() {
  local b=$1
  awk -v b="$b" 'BEGIN{
    split("B KB MB GB TB",u," ");
    i=1; while (b>=1024 && i<5) { b/=1024; i++ }
    printf "%.2f %s", b, u[i]
  }'
}

echo
echo "Matched: $count directories, ~$(human "$total_bytes")"

if [[ $count -eq 0 ]]; then
  echo "Nothing to clean."
  exit 0
fi

if [[ $APPLY -eq 0 ]]; then
  echo "Dry run. Re-run with --apply to delete."
  exit 0
fi

if [[ $ASSUME_YES -eq 0 ]]; then
  printf "Delete these %d directories? [y/N] " "$count"
  read -r reply
  case "$reply" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 1 ;;
  esac
fi

# Delete.
deleted=0
while IFS= read -r -d '' dir; do
  if rm -rf -- "$dir"; then
    deleted=$(( deleted + 1 ))
  else
    echo "Failed to remove: $dir" >&2
  fi
done < "$MATCHES_FILE"

echo "Deleted $deleted / $count directories. Freed ~$(human "$total_bytes")."