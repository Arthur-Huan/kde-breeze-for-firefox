# KDE Breeze for Firefox

A Firefox theme that emulates KDE's Breeze style in Firefox. This project provides CSS files to style Firefox's user interface, making it visually consistent with the KDE Plasma desktop environment.

## Features
- Breeze-inspired color scheme and icons
- Multiple color variants
- Easy installation and customization

## Files
- `kde-breeze.css`: Main Breeze theme for Firefox
- `kde-breeze-icons.css`: Breeze-inspired icons for Firefox

Color variants: Add alongside the previous two files for different colors

- `kde-breeze-colors-green.css`

## Installation

### Method 1 - Automatic installation:

   ```bash
   git clone https://github.com/Arthur-Huan/kde-breeze-for-firefox.git
   cd kde-breeze-for-firefox
   ./install.sh
   ```
   And then restart Firefox to apply the theme.
   
   **To install a supported color variant, use the `--color` flag with the script.**
   For example, to install the green variant:
   
   ```bash
   ./install.sh --color green
   ```
   The script will copy the corresponding color CSS file (e.g., `kde-breeze-colors-green.css`) in addition to the main theme files.

### Method 2 - Manual configuration:

**Set up userChrome** (skip if already configured):

1. Open Firefox and go to `about:config`.
2. Set `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`.
3. Open your Firefox profile folder. (Go to `about:support` and find "Profile Folder".)
4. Create a `chrome` folder inside your profile folder.
5. Create a `userChrome.css` file

**Apply the theme**

1. Copy the desired CSS file(s) from this repository into the `chrome` folder
2. Import the css files in `userChrome.css`.
   * For normal installation, import both `kde-breeze.css` and `kde-breeze-icons.css`.
   * For color variants, import the color variant's css file along with `kde-breeze-icons.css`.
3. Copy the `breeze-icons` and `breeze-dark-icons` folders into the `chrome` folder
4. Restart Firefox to apply the theme.

## Credits
- Inspired by KDE Plasma and the Breeze visual style
- Icons and design by the KDE community
