#!/usr/bin/env python3
"""
Apply minimalistic design system to FreshThreads HTML files.
This script updates HTML files to use the new design system.
"""

import os
import re
import glob
from pathlib import Path

def update_html_with_minimalistic_design(file_path):
    """Update HTML file to use minimalistic design system."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        original_content = content

        # 1. Add minimalistic CSS link if not present
        css_link = '<link rel="stylesheet" href="styles/minimalistic.css">'
        if 'minimalistic.css' not in content:
            # Find the head section and add the CSS link
            head_pattern = r'(<head[^>]*>)'
            if re.search(head_pattern, content, re.IGNORECASE):
                content = re.sub(
                    r'(</head>)',
                    f'    {css_link}\n\\1',
                    content,
                    flags=re.IGNORECASE
                )

        # 2. Update common HTML elements with minimalistic classes

        # Update header/nav elements
        content = re.sub(
            r'<header[^>]*>',
            '<header class="header">',
            content,
            flags=re.IGNORECASE
        )

        content = re.sub(
            r'<nav[^>]*>',
            '<nav class="nav container">',
            content,
            flags=re.IGNORECASE
        )

        # Update main containers
        content = re.sub(
            r'<main[^>]*>',
            '<main class="main">',
            content,
            flags=re.IGNORECASE
        )

        # Update section elements
        content = re.sub(
            r'<section([^>]*)>',
            lambda m: f'<section class="section{" " + m.group(1) if m.group(1).strip() else ""}">',
            content,
            flags=re.IGNORECASE
        )

        # Update button elements
        content = re.sub(
            r'<button([^>]*?)class="([^"]*)"([^>]*?)>',
            lambda m: f'<button{m.group(1)}class="btn btn-primary {m.group(2)}"{m.group(3)}>',
            content,
            flags=re.IGNORECASE
        )

        content = re.sub(
            r'<button([^>]*?)(?!class=)([^>]*?)>',
            r'<button\1class="btn btn-primary"\2>',
            content,
            flags=re.IGNORECASE
        )

        # Update links that look like buttons
        content = re.sub(
            r'<a([^>]*?)class="([^"]*?button[^"]*?)"([^>]*?)>',
            lambda m: f'<a{m.group(1)}class="btn btn-primary {m.group(2)}"{m.group(3)}>',
            content,
            flags=re.IGNORECASE
        )

        # Update footer
        content = re.sub(
            r'<footer[^>]*>',
            '<footer class="footer">',
            content,
            flags=re.IGNORECASE
        )

        # Add container classes to main content areas
        if 'class="container"' not in content:
            # Wrap main content in container
            content = re.sub(
                r'(<main[^>]*>)(.*?)(</main>)',
                r'\1<div class="container">\2</div>\3',
                content,
                flags=re.DOTALL | re.IGNORECASE
            )

        # 3. Update specific page elements based on file name
        filename = os.path.basename(file_path)

        if filename == 'index.html':
            # Add hero section classes
            content = re.sub(
                r'<div([^>]*?)class="([^"]*hero[^"]*)"([^>]*?)>',
                r'<div\1class="hero \2"\3>',
                content,
                flags=re.IGNORECASE
            )

        elif 'product' in filename:
            # Add product grid classes
            content = re.sub(
                r'<div([^>]*?)class="([^"]*product[^"]*grid[^"]*)"([^>]*?)>',
                r'<div\1class="product-grid \2"\3>',
                content,
                flags=re.IGNORECASE
            )

            content = re.sub(
                r'<div([^>]*?)class="([^"]*product[^"]*card[^"]*)"([^>]*?)>',
                r'<div\1class="product-card \2"\3>',
                content,
                flags=re.IGNORECASE
            )

        # Only write if content changed
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✓ Updated {os.path.basename(file_path)} with minimalistic design")
            return True
        else:
            print(f"- No changes needed for {os.path.basename(file_path)}")
            return True

    except Exception as e:
        print(f"✗ Error processing {file_path}: {e}")
        return False

def main():
    """Main function to update all HTML files."""
    docs_dir = Path(__file__).parent.parent / 'docs'
    html_files = glob.glob(str(docs_dir / '*.html'))

    print(f"🎨 Applying minimalistic design to {len(html_files)} HTML files...")
    print("📍 Design system: docs/styles/minimalistic.css")
    print("🎯 Target: Clean, bold, black & white aesthetic\n")

    # Ensure styles directory exists
    styles_dir = docs_dir / 'styles'
    styles_dir.mkdir(exist_ok=True)

    success_count = 0
    for html_file in html_files:
        if update_html_with_minimalistic_design(html_file):
            success_count += 1

    print(f"\n✅ Successfully updated {success_count}/{len(html_files)} files")
    print("\n🚀 Next steps:")
    print("1. Run 'make design-preview' to see the changes")
    print("2. Test responsive design on different screen sizes")
    print("3. Customize specific components as needed")
    print("4. Run 'make lint' to check code quality")

if __name__ == "__main__":
    main()
