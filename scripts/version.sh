#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

FALLBACK_VERSION=dev

described=$(git describe --tags --always --dirty 2>/dev/null || true)
version=${described#v}
echo "${version:-$FALLBACK_VERSION}"
