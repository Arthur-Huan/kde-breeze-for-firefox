#!/bin/bash
# This script sets up KDE Breeze styles in your Firefox profile.

set -e

# Supported colors
SUPPORTED_COLORS=(green purple red suse ubuntu yellow)
COLOR=""

# Parse --color argument
while [[ $# -gt 0 ]]; do
  case $1 in
    --color)
      COLOR="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Validate color if provided
if [[ -n "$COLOR" ]]; then
  FOUND=0
  for c in "${SUPPORTED_COLORS[@]}"; do
    if [[ "$c" == "$COLOR" ]]; then
      FOUND=1
      break
    fi
  done
  if [[ $FOUND -eq 0 ]]; then
    echo "Color '$COLOR' is not supported. Supported colors: ${SUPPORTED_COLORS[*]}"
    exit 1
  fi
fi

# 1. Find the default Firefox profile directory
FIREFOX_DIR="$HOME/.mozilla/firefox"
PROFILE=$(grep 'Path=' "$FIREFOX_DIR/profiles.ini" | head -n1 | cut -d'=' -f2)
PROFILE_DIR="$FIREFOX_DIR/$PROFILE"
CHROME_DIR="$PROFILE_DIR/chrome"

if [ ! -d "$PROFILE_DIR" ]; then
  echo "Could not find Firefox profile directory. Exiting."
  exit 1
fi

# 2. Ensure toolkit.legacyUserProfileCustomizations.stylesheets is enabled
PREF_FILE="$PROFILE_DIR/user.js"
PREF_LINE='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
if ! grep -q 'toolkit.legacyUserProfileCustomizations.stylesheets' "$PREF_FILE" 2>/dev/null; then
  echo "$PREF_LINE" >> "$PREF_FILE"
  echo "Enabled userChrome stylesheets in $PREF_FILE."
fi

# 3. Create chrome directory if it doesn't exist
mkdir -p "$CHROME_DIR"

# 4. Move CSS files into chrome directory
cp kde-breeze.css kde-breeze-icons.css "$CHROME_DIR/"
if [[ -n "$COLOR" ]]; then
  cp "colors/kde-breeze-colors-$COLOR.css" "$CHROME_DIR/"
fi

# 5. Create userChrome.css if it doesn't exist
USERCHROME="$CHROME_DIR/userChrome.css"
if [ ! -f "$USERCHROME" ]; then
  touch "$USERCHROME"
fi

# 6. Remove any lines containing kde-breeze*.css and add new imports
if [ -s "$USERCHROME" ]; then
  # Remove any lines that contain kde-breeze*.css
  sed -i '/kde-breeze.*\.css/d' "$USERCHROME"
fi

# Build the import statements
IMPORTS='@import "kde-breeze-icons.css";'
if [[ -n "$COLOR" ]]; then
  IMPORTS="$IMPORTS
@import \"kde-breeze-colors-$COLOR.css\";"
else
  IMPORTS="$IMPORTS
@import \"kde-breeze.css\";"
fi
TEMP_FILE=$(mktemp)
echo "$IMPORTS" > "$TEMP_FILE"
if [ -s "$USERCHROME" ]; then
  echo "" >> "$TEMP_FILE"  # Add blank line separator
  cat "$USERCHROME" >> "$TEMP_FILE"
fi
mv "$TEMP_FILE" "$USERCHROME"
echo "Added KDE Breeze imports to $USERCHROME."

echo "KDE Breeze theme installation completed successfully! \
Please restart Firefox for the changes to take effect."
