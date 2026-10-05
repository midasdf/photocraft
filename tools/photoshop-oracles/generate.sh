#!/bin/sh
# Regenerate corpus/photoshop with the installed Adobe Photoshop (macOS).
# Usage: tools/photoshop-oracles/generate.sh [filter-regex]   e.g. '^text/' or 'bevel-inner'
# Prints one line per file: ok / skip (feature not available in that mode) / FAIL.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
out=$(cd "$here/../.." && pwd)/corpus/photoshop
mkdir -p "$out"
exec "$here/run-jsx.sh" "$here/generate.jsx" "$out" "${1:-}"
