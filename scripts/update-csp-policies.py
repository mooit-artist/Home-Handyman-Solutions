#!/usr/bin/env python3
"""
Update incomplete CSP policies to full comprehensive policies.
This script replaces any existing CSP with the complete policy.
"""

import os
import re
import glob
from pathlib import Path

# Complete CSP policy
COMPLETE_CSP = 'default-src \'self\'; script-src \'self\' \'unsafe-inline\' https://cdn.jsdelivr.net https://unpkg.com https://ajax.googleapis.com https://cdnjs.cloudflare.com; style-src \'self\' \'unsafe-inline\' https://fonts.googleapis.com https://cdn.jsdelivr.net; font-src \'self\' https://fonts.gstatic.com; img-src \'self\' data: https: blob:; connect-src \'self\' https://api.printify.com https://fonts.googleapis.com; frame-src \'none\'; object-src \'none\'; base-uri \'self\'; form-action \'self\'; upgrade-insecure-requests;'

def update_csp_policy(file_path):
    """Update CSP policy in an HTML file to the complete version."""
    try:
        # Validate file path for security
        file_path = os.path.abspath(file_path)
        docs_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'docs'))

        if not file_path.startswith(docs_dir) or not file_path.endswith('.html'):
            return False

        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check if there's an existing CSP
        csp_pattern = r'<meta\s+http-equiv=["\']Content-Security-Policy["\'][^>]*content="[^"]*"[^>]*>'

        if re.search(csp_pattern, content, re.IGNORECASE):
            # Replace existing CSP with complete one
            new_csp = f'<meta http-equiv="Content-Security-Policy" content="{COMPLETE_CSP}">'
            new_content = re.sub(csp_pattern, new_csp, content, flags=re.IGNORECASE)

            if new_content != content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"✓ Updated CSP in {os.path.basename(file_path)}")
                return True
            else:
                print(f"- CSP already complete in {os.path.basename(file_path)}")
                return True
        else:
            print(f"- No CSP found in {os.path.basename(file_path)}")
            return True

    except Exception as e:
        print(f"✗ Error processing {file_path}: {e}")
        return False

def main():
    """Main function to update CSP policies in all HTML files."""
    docs_dir = Path(__file__).parent.parent / 'docs'
    html_files = glob.glob(str(docs_dir / '*.html'))

    print(f"🔄 Updating CSP policies in {len(html_files)} HTML files...\n")

    success_count = 0
    for html_file in html_files:
        if update_csp_policy(html_file):
            success_count += 1

    print(f"\n✅ Successfully processed {success_count}/{len(html_files)} files")

if __name__ == "__main__":
    main()
