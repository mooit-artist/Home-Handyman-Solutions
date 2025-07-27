#!/usr/bin/env python3
"""
Add Content Security Policy (CSP) headers to HTML files.
This script adds CSP meta tags to all HTML files in the docs directory.
"""

import os
import re
import glob
from pathlib import Path

# CSP policy for FreshThreads
CSP_POLICY = """
    <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://unpkg.com https://ajax.googleapis.com https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdn.jsdelivr.net; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https: blob:; connect-src 'self' https://api.printify.com https://fonts.googleapis.com; frame-src 'none'; object-src 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests;">

    <!-- Additional Security Headers -->
    <meta http-equiv="X-Content-Type-Options" content="nosniff">
    <meta http-equiv="X-Frame-Options" content="DENY">
    <meta http-equiv="X-XSS-Protection" content="1; mode=block">
    <meta http-equiv="Referrer-Policy" content="strict-origin-when-cross-origin">"""

def has_csp_policy(content):
    """Check if the HTML already has CSP policy."""
    return 'Content-Security-Policy' in content

def add_csp_to_html(file_path):
    """Add CSP policy to an HTML file."""
    try:
        # Validate file path for security
        file_path = os.path.abspath(file_path)
        docs_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'docs'))

        # Ensure file is within docs directory
        if not file_path.startswith(docs_dir):
            print(f"✗ File {file_path} is outside docs directory")
            return False

        # Ensure it's an HTML file
        if not file_path.endswith('.html'):
            print(f"✗ File {file_path} is not an HTML file")
            return False

        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Skip if CSP already exists
        if has_csp_policy(content):
            print(f"✓ CSP already exists in {file_path}")
            return True

        # Find the head section
        head_pattern = r'(<head[^>]*>)'
        match = re.search(head_pattern, content, re.IGNORECASE)

        if not match:
            print(f"✗ No <head> tag found in {file_path}")
            return False

        # Insert CSP after the opening head tag
        head_start = match.end()
        new_content = (
            content[:head_start] +
            '\n    <!-- Security Headers -->' +
            CSP_POLICY + '\n' +
            content[head_start:]
        )

        # Write the updated content
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)

        print(f"✓ Added CSP to {file_path}")
        return True

    except Exception as e:
        print(f"✗ Error processing {file_path}: {e}")
        return False

def main():
    """Main function to process all HTML files."""
    docs_dir = Path(__file__).parent.parent / 'docs'
    html_files = glob.glob(str(docs_dir / '*.html'))

    if not html_files:
        print("No HTML files found in docs directory")
        return

    print(f"Found {len(html_files)} HTML files")
    print("Adding CSP headers...\n")

    success_count = 0
    for html_file in html_files:
        if add_csp_to_html(html_file):
            success_count += 1

    print(f"\n✅ Successfully processed {success_count}/{len(html_files)} files")

if __name__ == "__main__":
    main()
