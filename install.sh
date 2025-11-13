#!/bin/bash
# This script sets up KDE Breeze styles in your Firefox profile.

set -e

COLOR=""
# Supported color variants
SUPPORTED_COLORS=(
    green
    purple
    red
    opensuse
    ubuntu
    yellow
    catppuccin-latte
    catppuccin-frappe
    catppuccin-macchiato
    catppuccin-mocha
    catppuccin-frappe-blue
    catppuccin-frappe-flamingo
    catppuccin-frappe-green
    catppuccin-frappe-lavendar
    catppuccin-frappe-maroon
    catppuccin-frappe-mauve
    catppuccin-frappe-peach
    catppuccin-frappe-pink
    catppuccin-frappe-red
    catppuccin-frappe-sapphire
    catppuccin-frappe-sky
    catppuccin-frappe-teal
    catppuccin-frappe-yellow
    catppuccin-latte-blue
    catppuccin-latte-flamingo
    catppuccin-latte-green
    catppuccin-latte-lavendar
    catppuccin-latte-maroon
    catppuccin-latte-mauve
    catppuccin-latte-peach
    catppuccin-latte-pink
    catppuccin-latte-red
    catppuccin-latte-sapphire
    catppuccin-latte-sky
    catppuccin-latte-teal
    catppuccin-latte-yellow
    catppuccin-macchiato-blue
    catppuccin-macchiato-flamingo
    catppuccin-macchiato-green
    catppuccin-macchiato-lavendar
    catppuccin-macchiato-maroon
    catppuccin-macchiato-mauve
    catppuccin-macchiato-peach
    catppuccin-macchiato-pink
    catppuccin-macchiato-red
    catppuccin-macchiato-sapphire
    catppuccin-macchiato-sky
    catppuccin-macchiato-teal
    catppuccin-macchiato-yellow
    catppuccin-mocha-blue
    catppuccin-mocha-flamingo
    catppuccin-mocha-green
    catppuccin-mocha-lavendar
    catppuccin-mocha-maroon
    catppuccin-mocha-mauve
    catppuccin-mocha-peach
    catppuccin-mocha-pink
    catppuccin-mocha-red
    catppuccin-mocha-sapphire
    catppuccin-mocha-sky
    catppuccin-mocha-teal
    catppuccin-mocha-yellow
)

show_help() {
    echo "Usage: $0 [--color <value>] [--help]"
    echo
    echo "Options:"
    echo "  --color <value>   Apply a color variant"
    echo "  --show-colors     Display the available color options"
    echo "  --help            Display this help message"
}

show_supported_colors() {
    echo "Supported colors:"
    printf "\t%s\n" "${SUPPORTED_COLORS[@]}"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --color)
            if [[ -z $2 || $2 == -* ]]; then
                echo "Error: --color requires a value"
                exit 1
            fi
            COLOR="$2"
            shift 2
            ;;
        --show-colors)
            show_supported_colors
            exit 0
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unrecognized argument '$1'"
            exit 1
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
    echo "Color '$COLOR' is not supported."
    exit 1
  fi
fi

if [[ -n "$COLOR" ]]; then
  INSTALL_CONFIRMATION_PROMPT="Proceed with installing the $COLOR color variant of the KDE Breeze for Firefox style? (y/N) "
else
  INSTALL_CONFIRMATION_PROMPT="Proceed with installing the KDE Breeze for Firefox style? (y/N) "
fi

read -p "$INSTALL_CONFIRMATION_PROMPT" response
case "$response" in
    [yY])
        echo "Proceeding..."
        sleep 0.5
        ;;
    *)
        echo "Exiting."
        exit 0
        ;;
esac


# 1. Find the default Firefox profile directory
# First, find path of .mozilla
POSSIBLE_DIRS=(
    "$HOME/.mozilla/firefox"
    "$HOME/snap/firefox/common/.mozilla/firefox"
    "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
)
FIREFOX_DIR_PATH=""
for DIR in "${POSSIBLE_DIRS[@]}"; do
    if [[ -d "$DIR" ]]; then
        FIREFOX_DIR_PATH="$DIR"
        break
    fi
done
if [[ -z "$FIREFOX_DIR_PATH" ]]; then
    echo "Couldn't determine the location of the Firefox data directory."
    exit 1
fi
# Next, search for the default profile in profiles.ini
PROFILES_INI="$FIREFOX_DIR_PATH/profiles.ini"
if [[ $(grep '\[Profile[^0]\]' "$PROFILES_INI") ]]; then
    PROFILE_DIR=$(grep -E '^\[Profile|^Path|^Default' "$PROFILES_INI" | grep -1 '^Default=1' | grep '^Path' | cut -c6-)
else
    PROFILE_DIR=$(grep 'Path=' "$PROFILES_INI" | sed 's/^Path=//')
fi
PROFILE_DIR="$FIREFOX_DIR_PATH/$PROFILE_DIR"
echo "Using Firefox profile directory: $PROFILE_DIR"


# 2. Ensure toolkit.legacyUserProfileCustomizations.stylesheets is enabled
PREF_FILE="$PROFILE_DIR/user.js"
PREF_LINE='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
if ! grep -q 'toolkit.legacyUserProfileCustomizations.stylesheets' "$PREF_FILE" 2>/dev/null; then
  echo "$PREF_LINE" >> "$PREF_FILE"
  echo "Enabled userChrome stylesheets in $PREF_FILE."
fi


# 3. Create chrome directory if it doesn't exist
CHROME_DIR="$PROFILE_DIR/chrome"
if [ ! -d "$CHROME_DIR" ]; then
    mkdir -p "$CHROME_DIR"
    echo "Created directory: $CHROME_DIR"
fi


# 4a. Move CSS files into chrome directory
cp kde-breeze.css kde-breeze-icons.css "$CHROME_DIR/"
# 4b. Copy icons directories into chrome directory
cp -r breeze-icons "$CHROME_DIR/"
cp -r breeze-dark-icons "$CHROME_DIR/"
echo "CSS files and icons have been copied."


# 5. Apply color variant (if applicable) snippet to the end of kde-breeze.css
if [[ -n "$COLOR" ]]; then
  SOURCE_FILE="colors/$COLOR.css"
  TARGET_FILE="$CHROME_DIR/kde-breeze.css"

  if [[ -f "$SOURCE_FILE" ]]; then
    # Append color variant contents
    echo "" >> "$TARGET_FILE"
    cat "$SOURCE_FILE" >> "$TARGET_FILE"
    echo "Successfully appended color variant '$COLOR' to $TARGET_FILE"
  else
    echo "Warning: Color variant file '$SOURCE_FILE' not found — skipping."
  fi
fi


# 6. Create userChrome.css if it doesn't exist
USERCHROME="$CHROME_DIR/userChrome.css"
if [ ! -f "$USERCHROME" ]; then
  touch "$USERCHROME"
  echo "Created userChrome.css at $USERCHROME"
fi


# 7. Add imports to userChrome.css
# First, remove any previous imports, including past obsolete files
sed -i '/kde-breeze\.css/d;
      /kde-breeze-icons\.css/d;
      /kde-breeze-colors-.*\.css/d' "$USERCHROME"
# Next, prepend the imports
IMPORT_BLOCK='@import "kde-breeze.css";
@import "kde-breeze-icons.css";'
TEMP_FILE=$(mktemp)
echo "$IMPORT_BLOCK" > "$TEMP_FILE"
echo "" >> "$TEMP_FILE"  # Blank line
cat "$USERCHROME" >> "$TEMP_FILE"
mv "$TEMP_FILE" "$USERCHROME"
echo "Imports added to $USERCHROME"


echo ""
echo "KDE Breeze theme installation completed successfully! \
Please restart Firefox for the changes to take effect."

