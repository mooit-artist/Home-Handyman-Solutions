# Gallery Google Drive Setup Instructions

## Overview
The gallery page is now configured to display images from Google Drive. This allows customers to easily share their project photos, and you can manage the gallery by updating the image URLs in the code.

## How to Add Images to the Gallery

### Step 1: Get Google Drive Image URL
1. Upload the image to Google Drive
2. Right-click the image → Select "Get link"
3. Change sharing to "Anyone with the link"
4. Copy the sharing URL (it will look like: `https://drive.google.com/file/d/FILE_ID/view?usp=sharing`)
5. Extract the FILE_ID from the URL (the long string between `/d/` and `/view`)
6. Convert to direct image URL: `https://drive.google.com/uc?id=FILE_ID`

### Step 2: Update the Gallery Code
1. Open `gallery.html`
2. Find the `googleDriveImages` object at the top of the file (around line 19)
3. Add the Google Drive URL to the appropriate project:

```javascript
const googleDriveImages = {
    // Example:
    'drywall-repair-1': 'https://drive.google.com/uc?id=YOUR_FILE_ID_HERE',
    'drywall-basement-1': 'https://drive.google.com/uc?id=ANOTHER_FILE_ID',
    // ... etc
};
```

### Step 3: Available Image Slots
The following IDs are available for images:

**Drywall Projects:**
- `drywall-repair-1` - Living Room Wall Repair
- `drywall-basement-1` - Basement Finishing

**Deck Projects:**
- `deck-restoration-1` - Complete Deck Restoration
- `deck-board-replacement-1` - Deck Board Replacement

**Electrical Projects:**
- `electrical-kitchen-1` - Kitchen Outlet Installation
- `electrical-ceiling-fan-1` - Ceiling Fan Installation

**Bathroom Projects:**
- `bathroom-tile-1` - Shower Tile Replacement
- `bathroom-vanity-1` - Vanity & Faucet Installation

**Painting Projects:**
- `painting-interior-1` - Living Room Paint Job
- `painting-exterior-1` - Exterior Trim Painting

## Customer Instructions
The gallery page now includes instructions for customers on how to share their photos:

1. Upload photos to Google Drive
2. Share with "Anyone with the link"
3. Email the link to info@homehandymansolutions.com
4. You'll add it to the gallery with their permission

## Features
- **Automatic Loading**: Images load automatically when the page loads
- **Error Handling**: If an image fails to load, it shows an error message
- **Placeholders**: Projects without images show "Image Coming Soon" placeholders
- **Modal View**: Clicking images opens them in a larger modal view
- **Responsive**: Works on mobile and desktop devices
- **Filter System**: Images work with the existing category filter system

## Troubleshooting
- **Image not showing**: Check that the Google Drive link is set to "Anyone with the link"
- **Wrong image format**: Make sure you're using the `uc?id=` format, not the regular sharing link
- **Loading errors**: Check the browser console for specific error messages

## Adding New Projects
To add new project cards:

1. Add a new entry to the `googleDriveImages` object with a unique ID
2. Create a new project card div with the corresponding ID in the `project-image` element
3. Follow the existing structure and styling
