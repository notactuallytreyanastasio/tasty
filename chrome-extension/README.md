# Tasty Chrome Extension

A Chrome extension for saving bookmarks to the Tasty social bookmarking service.

## Features

- One-click bookmark saving
- Tag management
- Public/private bookmark settings
- Integration with Tasty web application

## Installation

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked" and select this directory
4. The Tasty extension should now appear in your extensions

## Usage

1. Navigate to any webpage you want to bookmark
2. Click the Tasty extension icon in your browser toolbar
3. Sign in with your Tasty account (or register if you don't have one)
4. Add tags and description if desired
5. Choose whether to make the bookmark public or private
6. Click "Save Bookmark"

## Development

The extension communicates with the Tasty API running on `localhost:4000`. Make sure the Phoenix server is running before testing the extension.

### Files

- `manifest.json` - Extension configuration
- `popup.html` - Extension popup interface
- `popup.css` - Styling for the popup
- `popup.js` - JavaScript functionality
- `icon-*.png` - Extension icons (placeholder files needed)

### TODO

- Add actual icon files (currently using placeholders)
- Implement proper authentication flow
- Add error handling for network failures
- Add support for editing existing bookmarks
- Add bookmark search functionality