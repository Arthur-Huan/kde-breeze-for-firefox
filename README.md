# KDE Breeze for Firefox

A Firefox theme that emulates KDE's Breeze style in Firefox. This project provides CSS files to style Firefox's user interface, making it visually consistent with the KDE Plasma desktop environment.

## Features
- Breeze-inspired color scheme and icons
- Multiple color variants
- Easy installation and customization

## Files
- `kde-breeze.css`: Main Breeze theme for Firefox
- `kde-breeze-icons.css`: Breeze-inspired icons for Firefox

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

### Method 2 - Manual configuration:

**Set up userChrome** (skip if already configured):

1. Open Firefox and go to `about:config`.
2. Set `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`.
3. Open your Firefox profile folder. (Go to `about:support` and find "Profile Folder".)
4. Create a `chrome` folder inside your profile folder.
5. Create a `userChrome.css` file

**Apply the theme**

1. Copy the desired CSS file(s) from this repository into the `chrome` folder
2. Import the `kde-breeze.css` and `kde-breeze-icons.css` css files in `userChrome.css`.
3. (Optional) Apply color variants:
      * Copy the snippets in the colors css files to the end of the `kde-breeze.css` file
      * Alternatively, edit the root variables in `kde-breeze.css` with the preferred tweaks
3. Copy the `breeze-icons` and `breeze-dark-icons` folders into the `chrome` folder
4. Restart Firefox to apply the theme.

## Credits
- Inspired by KDE Plasma and the Breeze visual style
- Icons and design by the KDE community
- Certain color scheme designs by Canonical's Yaru team, the openSUSE community, and the Catppuccin community.
