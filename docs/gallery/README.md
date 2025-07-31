# Gallery Images Directory

This directory contains all the project images for the gallery page.

## Current Directory Structure

```
gallery/
├── 814/                    (legacy folder - can be cleaned up)
└── README.md              (this file)
```

**Note**: The image structure described below is the intended structure once images are added.

## Planned Image Directory Structure

```
gallery/images/
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

## Image Requirements

- **Format**: JPG, PNG, or WebP
- **Size**: Minimum 800px wide for best quality
- **Aspect Ratio**: 4:3 or 16:9 recommended
- **File Size**: Keep under 2MB for fast loading

## File Naming Convention

Use the exact filenames shown above. The gallery page expects these specific names.

## Adding New Images

1. **Create the directory structure first**:
   ```bash
   mkdir -p gallery/images/{drywall,deck,electrical,bathroom,painting}
   ```

2. **For customers**: Email photos to info@homehandymansolutionsllc.com

3. **For developers**: Upload images to the appropriate category folder with the correct filename

4. **For additional projects**: You can add new numbered images (e.g., `drywall-repair-2.jpg`) and update the gallery.html accordingly

## Setup Instructions

To set up the gallery structure from scratch:

1. Create the images directory and subdirectories
2. Add your project photos with the naming convention below
3. Update the gallery.html file to reference the new images

## Cleanup Tasks

- Remove the `814/` folder if no longer needed
- Remove `.DS_Store` files (macOS system files)

## Backup

Keep backups of all images in a separate location before making changes.
