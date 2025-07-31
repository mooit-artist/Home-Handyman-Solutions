# Gallery Images Directory

This directory contains all the project images for the gallery page.

## Current Directory Structure

```
gallery/
├── 814/                    (legacy folder - check for images to migrate)
├── images/                 (NEW - organized gallery structure)
│   ├── drywall/
│   ├── deck/
│   ├── electrical/
│   ├── bathroom/
│   ├── painting/
│   └── README-INSTRUCTIONS.md
└── README.md              (this file)
```

**Status**: Gallery structure created! Ready for images from 814 folder or new uploads.

## Gallery Image Directory Structure

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

1. **Directory structure is ready!** ✅

2. **If you have images in the 814 folder:**
   ```bash
   # Check what's in 814 folder
   ls -la docs/gallery/814/

   # Move and rename images to proper locations
   # Example:
   # mv docs/gallery/814/your-image.jpg docs/gallery/images/drywall/drywall-repair-1.jpg
   ```

3. **For new customer photos**: Email to info@homehandymansolutionsllc.com

4. **For developers**: Upload images to the appropriate category folder with the correct filename

5. **For additional projects**: Add numbered images (e.g., `drywall-repair-2.jpg`) and update gallery.html

## Migration from 814 Folder

If you find images in the 814 folder, see `docs/gallery/images/README-INSTRUCTIONS.md` for detailed migration steps.

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
