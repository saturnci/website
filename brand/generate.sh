#!/bin/bash

# Generates brand assets (OG image, favicon, logos) from HTML source files.
# Run from the website project root: ./brand/generate.sh

BRAND_DIR="$(cd "$(dirname "$0")" && pwd)"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# OG image (1200x630)
"$CHROME" --headless --disable-gpu --hide-scrollbars \
  --screenshot="$BRAND_DIR/../src/images/og-image.png" \
  --window-size=1200,630 \
  "file://$BRAND_DIR/og-image.html"

# Favicon (256px, then scaled to 32px)
"$CHROME" --headless --disable-gpu --hide-scrollbars \
  --screenshot="$BRAND_DIR/favicon-256.png" \
  --window-size=256,256 \
  --default-background-color=00000000 \
  "file://$BRAND_DIR/favicon.html"
sips -z 32 32 "$BRAND_DIR/favicon-256.png" --out "$BRAND_DIR/../src/assets/favicon.png"
cp "$BRAND_DIR/favicon-256.png" "$BRAND_DIR/../src/assets/apple-touch-icon.png"

# Logo - indigo on transparent
"$CHROME" --headless --disable-gpu --hide-scrollbars \
  --screenshot="$BRAND_DIR/saturnci-logo-indigo.png" \
  --window-size=1200,300 \
  --default-background-color=00000000 \
  "file://$BRAND_DIR/logo-indigo.html"

# Logo - white on transparent
"$CHROME" --headless --disable-gpu --hide-scrollbars \
  --screenshot="$BRAND_DIR/saturnci-logo-white.png" \
  --window-size=1200,300 \
  --default-background-color=00000000 \
  "file://$BRAND_DIR/logo-white.html"

echo "Brand assets generated."
