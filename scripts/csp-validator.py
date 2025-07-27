#!/usr/bin/env python3
"""
Content Security Policy (CSP) Validation and Reporting Tool
This script validates CSP implementation across all HTML files.
"""

import os
import re
import glob
import json
from pathlib import Path
from datetime import datetime

def check_csp_in_file(file_path):
    """Check CSP implementation in an HTML file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check for CSP meta tag - use direct content extraction
        csp_meta_pattern = r'<meta\s+http-equiv=["\']Content-Security-Policy["\'][^>]*>'
        csp_match = re.search(csp_meta_pattern, content, re.IGNORECASE)

        if not csp_match:
            return {
                'has_csp': False,
                'policy': None,
                'directives': [],
                'security_headers': []
            }

        # Extract the content attribute value from the specific CSP meta tag
        csp_tag = csp_match.group(0)
        content_pattern = r'content="([^"]*)"'
        content_match = re.search(content_pattern, csp_tag)
        if not content_match:
            # Try single quotes
            content_pattern = r"content='([^']*)'"
            content_match = re.search(content_pattern, csp_tag)

        if not content_match:
            return {
                'has_csp': False,
                'policy': None,
                'directives': [],
                'security_headers': []
            }

        # Extract policy content directly from the match
        policy = content_match.group(1).strip()        # Parse directives
        directives = []
        # Clean up the policy string and split by semicolons
        clean_policy = re.sub(r'\s+', ' ', policy).strip()
        for directive in clean_policy.split(';'):
            directive = directive.strip()
            if directive:
                directives.append(directive)

        # Check for additional security headers
        security_headers = []
        headers_to_check = [
            'X-Content-Type-Options',
            'X-Frame-Options',
            'X-XSS-Protection',
            'Referrer-Policy'
        ]

        for header in headers_to_check:
            header_pattern = f'<meta\\s+http-equiv=["\']({header})["\'][^>]*>'
            if re.search(header_pattern, content, re.IGNORECASE):
                security_headers.append(header)

        return {
            'has_csp': True,
            'policy': policy,
            'directives': directives,
            'security_headers': security_headers
        }

    except Exception as e:
        return {
            'has_csp': False,
            'error': str(e),
            'policy': None,
            'directives': [],
            'security_headers': []
        }

def validate_csp_policy(directives):
    """Validate CSP policy directives."""
    issues = []
    recommendations = []

    # Check for essential directives
    essential_directives = ['default-src', 'script-src', 'style-src']
    found_directives = [d.split()[0] for d in directives]

    for directive in essential_directives:
        if directive not in found_directives:
            issues.append(f"Missing essential directive: {directive}")

    # Check for security best practices
    for directive in directives:
        parts = directive.split()
        if len(parts) < 2:
            continue

        directive_name = parts[0]
        values = parts[1:]

        # Check for unsafe directives
        if "'unsafe-eval'" in values:
            issues.append(f"{directive_name} allows 'unsafe-eval' which can be dangerous")

        if "'unsafe-inline'" in values and directive_name == 'script-src':
            recommendations.append(f"Consider removing 'unsafe-inline' from {directive_name} and using nonces or hashes")

        # Check for wildcard usage
        if '*' in values:
            recommendations.append(f"{directive_name} uses wildcard (*) - consider being more specific")

    return issues, recommendations

def generate_report():
    """Generate comprehensive CSP report."""
    docs_dir = Path(__file__).parent.parent / 'docs'
    html_files = glob.glob(str(docs_dir / '*.html'))

    report = {
        'timestamp': datetime.now().isoformat(),
        'total_files': len(html_files),
        'files_with_csp': 0,
        'files_without_csp': 0,
        'file_details': {},
        'overall_issues': [],
        'overall_recommendations': []
    }

    print(f"🔍 Analyzing {len(html_files)} HTML files for CSP compliance...\n")

    for html_file in html_files:
        filename = os.path.basename(html_file)
        result = check_csp_in_file(html_file)

        if result['has_csp']:
            report['files_with_csp'] += 1
            issues, recommendations = validate_csp_policy(result['directives'])

            print(f"✅ {filename}")
            print(f"   📋 Directives: {len(result['directives'])}")
            print(f"   🛡️  Security headers: {len(result['security_headers'])}")

            if issues:
                print(f"   ⚠️  Issues: {len(issues)}")
                for issue in issues:
                    print(f"      • {issue}")

            if recommendations:
                print(f"   💡 Recommendations: {len(recommendations)}")
                for rec in recommendations[:2]:  # Show first 2
                    print(f"      • {rec}")

            result['issues'] = issues
            result['recommendations'] = recommendations
        else:
            report['files_without_csp'] += 1
            print(f"❌ {filename} - No CSP found")

        report['file_details'][filename] = result
        print()

    # Summary
    print("📊 CSP COMPLIANCE SUMMARY")
    print("=" * 40)
    print(f"Total HTML files: {report['total_files']}")
    print(f"Files with CSP: {report['files_with_csp']}")
    print(f"Files without CSP: {report['files_without_csp']}")
    print(f"Compliance rate: {(report['files_with_csp']/report['total_files']*100):.1f}%")

    # Overall recommendations
    all_issues = []
    all_recommendations = []

    for file_data in report['file_details'].values():
        if 'issues' in file_data:
            all_issues.extend(file_data['issues'])
        if 'recommendations' in file_data:
            all_recommendations.extend(file_data['recommendations'])

    if all_issues:
        print(f"\n⚠️  Common Issues Found:")
        unique_issues = list(set(all_issues))
        for issue in unique_issues[:5]:
            print(f"   • {issue}")

    if all_recommendations:
        print(f"\n💡 Common Recommendations:")
        unique_recs = list(set(all_recommendations))
        for rec in unique_recs[:3]:
            print(f"   • {rec}")

    print(f"\n📄 Detailed report saved to: csp-report.json")

    # Save detailed report
    with open('csp-report.json', 'w') as f:
        json.dump(report, f, indent=2)

    return report

if __name__ == "__main__":
    generate_report()
