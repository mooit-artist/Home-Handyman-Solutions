# Gallery Static Image Setup Instructions

## Overview
The gallery page now uses a static HTML/CSS approach with images stored in a structured directory system. This allows for simple file uploads and automatic display without any JavaScript configuration.

## Directory Structure

```
docs/gallery/images/
├── drywall/
│   ├── drywall-repair-1.jpg
│   └── drywall-basement-1.jpg
├── deck/
│   ├── deck-restoration-1.jpg
│   └── deck-board-replacement-1.jpg
├── electrical/
│   ├── electrical-kitchen-1.jpg
│   └── electrical-ceiling-fan-1.jpg
├── bathroom/
│   ├── bathroom-tile-1.jpg
│   └── bathroom-vanity-1.jpg
└── painting/
    ├── painting-interior-1.jpg
    └── painting-exterior-1.jpg
```

## How to Add Images

### Step 1: Prepare Images
- **Format**: JPG, PNG, or WebP
- **Size**: Minimum 800px wide for best quality
- **Optimization**: Compress images to keep under 2MB

### Step 2: Upload to Correct Directory
1. Navigate to the appropriate category folder
2. Upload the image with the exact filename shown above
3. The image will automatically appear on the gallery page

### Step 3: Available Image Slots

**Drywall Projects:**
- `drywall-repair-1.jpg` - Living Room Wall Repair
- `drywall-basement-1.jpg` - Basement Finishing

**Deck Projects:**
- `deck-restoration-1.jpg` - Complete Deck Restoration
- `deck-board-replacement-1.jpg` - Deck Board Replacement

**Electrical Projects:**
- `electrical-kitchen-1.jpg` - Kitchen Outlet Installation
- `electrical-ceiling-fan-1.jpg` - Ceiling Fan Installation

**Bathroom Projects:**
- `bathroom-tile-1.jpg` - Shower Tile Replacement
- `bathroom-vanity-1.jpg` - Vanity & Faucet Installation

**Painting Projects:**
- `painting-interior-1.jpg` - Living Room Paint Job
- `painting-exterior-1.jpg` - Exterior Trim Painting

## Customer Process

### For Customers:
1. Take high-quality photos of completed project
2. Email photos to info@homehandymansolutions.com
3. Include project details (location, type of work, timeline)
4. Company will process and upload images

### For Website Administrators:
1. Receive customer photos via email
2. Optimize images (resize, compress)
3. Rename to appropriate filename
4. Upload to correct directory via FTP/file manager
5. Images appear automatically on website

## Features

- **No Code Changes**: Simply upload images with correct filenames
- **Automatic Fallback**: Shows placeholder text when images aren't available
- **Responsive Design**: Images scale properly on all devices
- **Modal View**: Click images to view them larger
- **Category Filtering**: Works with existing filter system
- **Fast Loading**: Direct file serving, no external dependencies

## Adding New Project Slots

To add more projects (e.g., `drywall-repair-2.jpg`):

1. **Add HTML**: Copy an existing project card in `gallery.html`
2. **Update Image Path**: Change `src` to new filename
3. **Update Content**: Modify project title, description, details
4. **Upload Image**: Add the image file to the appropriate directory

## Troubleshooting

- **Image not showing**: Check filename matches exactly (case-sensitive)
- **Wrong size**: Verify image dimensions are adequate
- **Slow loading**: Compress images to reduce file size
- **Permission errors**: Ensure proper file permissions on server

## File Management Tips

- Keep image backups in a separate location
- Use descriptive original filenames before renaming
- Test images on different devices and screen sizes
- Consider using WebP format for better compression
- Maintain consistent aspect ratios for better layout
