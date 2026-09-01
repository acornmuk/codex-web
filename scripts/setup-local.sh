#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NODE_DIR="$PROJECT_DIR/.tools/node-v24.20.0-linux-x64"
ASSET_DIR="$PROJECT_DIR/.cache"
ASSET_VERSION="26.707.30751"
ASSET_FILE="$ASSET_DIR/ChatGPT-darwin-arm64-$ASSET_VERSION.zip"
ASSET_URL="https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-$ASSET_VERSION.zip"
ASSET_SHA256="f81023845ae56ebb98b349e4bc81d7b490533564897cea0ea4fc4a17104f3892"

if [[ ! -x "$NODE_DIR/bin/node" ]]; then
  echo "Project Node runtime is missing: $NODE_DIR" >&2
  exit 1
fi

export PATH="$NODE_DIR/bin:$PROJECT_DIR/scripts/local:$PATH"
cd "$PROJECT_DIR"

mkdir -p "$ASSET_DIR"
if [[ ! -f "$ASSET_FILE" ]]; then
  curl --fail --location --retry 3 --output "$ASSET_FILE.part" "$ASSET_URL"
  mv "$ASSET_FILE.part" "$ASSET_FILE"
fi

printf '%s  %s\n' "$ASSET_SHA256" "$ASSET_FILE" | sha256sum --check

npm ci --ignore-scripts
rm -rf "$PROJECT_DIR/scratch"
HOSTED_CODEX_APP_ZIP="$ASSET_FILE" npm run prepare:asar
rm -rf "$PROJECT_DIR/scratch/ChatGPT.app"
npm rebuild better-sqlite3 node-pty
npm run build:browser
npm run build:server

echo "codex-web local build is ready."
