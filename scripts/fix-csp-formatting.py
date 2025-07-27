#!/usr/bin/env python3
"""
Fix CSP formatting in existing HTML files.
This script replaces multi-line CSP policies with single-line format for proper parsing.
"""

import os
import re
import glob
from pathlib import Path

def fix_csp_formatting(file_path):
    """Fix CSP formatting in an HTML file."""
    try:
        # Validate file path for security
        file_path = os.path.abspath(file_path)
        docs_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'docs'))

        # Ensure file is within docs directory
        if not file_path.startswith(docs_dir):
            print(f"✗ File {file_path} is outside docs directory")
            return False

        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Find multi-line CSP policy
        csp_pattern = r'<meta\s+http-equiv=["\']Content-Security-Policy["\'][^>]*content=["\']([^"\']*(?:\s*[^"\']*)*)["\'][^>]*>'

        # New single-line CSP policy
        new_csp = '<meta http-equiv="Content-Security-Policy" content="default-src \'self\'; script-src \'self\' \'unsafe-inline\' https://cdn.jsdelivr.net https://unpkg.com https://ajax.googleapis.com https://cdnjs.cloudflare.com; style-src \'self\' \'unsafe-inline\' https://fonts.googleapis.com https://cdn.jsdelivr.net; font-src \'self\' https://fonts.gstatic.com; img-src \'self\' data: https: blob:; connect-src \'self\' https://api.printify.com https://fonts.googleapis.com; frame-src \'none\'; object-src \'none\'; base-uri \'self\'; form-action \'self\'; upgrade-insecure-requests;">'

        # Replace the CSP policy
        new_content = re.sub(csp_pattern, new_csp, content, flags=re.MULTILINE | re.DOTALL)

        if new_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"✓ Fixed CSP formatting in {os.path.basename(file_path)}")
            return True
        else:
            print(f"- No changes needed in {os.path.basename(file_path)}")
            return True

    except Exception as e:
        print(f"✗ Error processing {file_path}: {e}")
        return False

def main():
    """Main function to fix CSP formatting in all HTML files."""
    docs_dir = Path(__file__).parent.parent / 'docs'
    html_files = glob.glob(str(docs_dir / '*.html'))

    print(f"🔧 Fixing CSP formatting in {len(html_files)} HTML files...\n")

    success_count = 0
    for html_file in html_files:
        if fix_csp_formatting(html_file):
            success_count += 1

    print(f"\n✅ Successfully processed {success_count}/{len(html_files)} files")

if __name__ == "__main__":
    main()
