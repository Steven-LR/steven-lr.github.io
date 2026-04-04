#!/usr/bin/env bash
# Usage (from the steven-lr.github.io directory):
#   ./publish-app.sh
#
# What it does:
#   1. Regenerates the BYM2 Explorer preview screenshot
#   2. Stages all changes (apps/, assets/, etc.)
#   3. Commits with a timestamped message and pushes to origin/main

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_HTML="$SCRIPT_DIR/apps/bym2_explorer.html"
PREVIEW_PNG="$SCRIPT_DIR/assets/img/bym2-explorer-preview.png"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

echo "==> Regenerating preview screenshot..."
if [[ -x "$CHROME" ]]; then
  "$CHROME" \
    --headless=new \
    --disable-gpu \
    --hide-scrollbars \
    --screenshot="$PREVIEW_PNG" \
    --window-size=1400,850 \
    --default-background-color=000000 \
    "file://$APP_HTML" 2>/dev/null
  echo "    Screenshot saved: assets/img/bym2-explorer-preview.png"
else
  echo "    [warn] Chrome not found at expected path; skipping screenshot."
fi

echo "==> Staging changes..."
cd "$SCRIPT_DIR"
git add -A

if git diff --cached --quiet; then
  echo "    Nothing new to commit."
  exit 0
fi

TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
echo "==> Committing and pushing..."
git commit -m "update app + preview ($TIMESTAMP)"
git push

echo "==> Done. GitHub Pages will rebuild in ~30–60 seconds."
