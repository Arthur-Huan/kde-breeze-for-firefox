#!/bin/bash
# This script uninstalls the KDE Breeze styles from your Firefox profile.

set -e

POSSIBLE_DIRS=(
    "$HOME/.mozilla/firefox"
    "$HOME/snap/firefox/common/.mozilla/firefox"
    "$HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox"
)

show_help() {
    echo "Usage: $0 [--dir <path>] [--help]"
    echo
    echo "Options:"
    echo "  --dir <path>  Uninstall from the specified Firefox profile directory only."
    echo "  --help                     Show this help message."
    echo
    echo "If no arguments are given, the script will uninstall from all detected Firefox profiles."
}

PROFILE_DIR_ARRAY=()
# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dir)
            if [[ -z $2 || $2 == -* ]]; then
                echo "Error: --dir requires a value"
                exit 1
            fi
            PROFILE_DIR_ARRAY=("$(realpath "$2")")
            shift 2
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

echo "Warning: This script will permanently delete files and directories from your Firefox profiles."
echo "It is highly recommended to back up your profiles or manually delete the files from the chrome directory."

# 1a. If a directory was specified, verify it exists and use it
if [ -n "${PROFILE_DIR_ARRAY[0]}" ]; then
    if [ ! -d "${PROFILE_DIR_ARRAY[0]}" ]; then
        echo "Provided Firefox directory '${PROFILE_DIR_ARRAY[0]}' does not exist."
        exit 1
    fi
# 1b. If no directory was specified, search for all Firefox profiles
else
    for base_dir in "${POSSIBLE_DIRS[@]}"; do
        if [ -d "$base_dir" ]; then
            PROFILES_INI="$base_dir/profiles.ini"
            if [ -f "$PROFILES_INI" ]; then
                while IFS= read -r profile_path; do
                    if [ -n "$profile_path" ]; then
                        PROFILE_DIR_ARRAY+=("$base_dir/$profile_path")
                    fi
                done < <(grep '^Path=' "$PROFILES_INI" | sed 's/^Path=//')
            fi
        fi
    done
fi

# 2. Ask user confirmation of the directories to uninstall from
echo "The following Firefox profile directories will be uninstalled from:"
for dir in "${PROFILE_DIR_ARRAY[@]}"; do
    echo "    $dir"
done
read -p "Uninstall theme from all specified directories? [y/N] " response
case "$response" in
    [yY])
        sleep 0.5
        ;;
    *)
        echo "Uninstallation aborted."
        exit 0
        ;;
esac

# 3. Ask for user confirmation of the contents that will be deleted
echo ""
echo "The following will be deleted from each profile's chrome directory:"
echo "    kde-breeze.css"
echo "    kde-breeze-icons.css"
echo "    breeze-dark-icons (directory)"
echo "    breeze-icons (directory)"
echo "    \"@import kde-breeze.css\" in userChrome.css"
echo "    \"@import kde-breeze-icons.css\" in userChrome.css"
read -p "Continue with uninstallation? [y/N] " response
case "$response" in
    [yY])
        echo "Proceeding..."
        echo ""
        sleep 0.5
        ;;
    *)
        echo "Uninstallation aborted."
        exit 0
        ;;
esac

# 4. Uninstall from each profile directory
for PROFILE_DIR in "${PROFILE_DIR_ARRAY[@]}"; do
    CHROME_DIR="$PROFILE_DIR/chrome"

    if [ ! -d "$CHROME_DIR" ]; then
        echo "Skipping $PROFILE_DIR: chrome directory not found."
        continue
    fi

    # Delete files and directories
    rm -rf "$CHROME_DIR/breeze-dark-icons" "$CHROME_DIR/breeze-icons"
    rm -f "$CHROME_DIR/kde-breeze.css" "$CHROME_DIR/kde-breeze-icons.css"
    
    # Remove `@import` statements from `userChrome.css`
    USERCHROME="$CHROME_DIR/userChrome.css"
    if [ -f "$USERCHROME" ]; then
        sed -i '/@import "kde-breeze\.css";/d; /@import "kde-breeze-icons\.css";/d' "$USERCHROME"
    fi

    echo "Uninstalled from $PROFILE_DIR."
done

echo ""
echo "KDE Breeze theme uninstallation completed successfully! \
Please restart Firefox for the changes to take effect."
