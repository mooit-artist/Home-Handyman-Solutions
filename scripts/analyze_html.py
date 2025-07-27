#!/usr/bin/env python3
"""
FreshThreads LLC - HTML Analysis Tool
Analyze HTML files for GitHub Pages compatibility and optimization opportunities.
"""

import os
import sys
import json
from pathlib import Path
from typing import List, Dict, Any
from dataclasses import dataclass
import argparse

try:
    from bs4 import BeautifulSoup
    import requests
    from PIL import Image
    import yaml
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    print("Run 'make python-setup' to install required packages")
    sys.exit(1)


@dataclass
class AnalysisResult:
    """Result of HTML file analysis."""
    file_path: str
    title: str
    meta_description: str
    image_count: int
    link_count: int
    script_count: int
    issues: List[str]
    recommendations: List[str]
    github_pages_compatible: bool


class HTMLAnalyzer:
    """Analyze HTML files for FreshThreads project."""

    def __init__(self, docs_dir: str = "docs"):
        self.docs_dir = Path(docs_dir)
        self.results: List[AnalysisResult] = []

    def analyze_file(self, file_path: Path) -> AnalysisResult:
        """Analyze a single HTML file."""
        print(f"🔍 Analyzing {file_path}")

        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        soup = BeautifulSoup(content, 'html.parser')

        # Extract basic info
        title = soup.title.string if soup.title else "No title"
        meta_desc = ""
        meta_description = soup.find('meta', attrs={'name': 'description'})
        if meta_description:
            meta_desc = meta_description.get('content', '')

        # Count elements
        images = soup.find_all('img')
        links = soup.find_all('a')
        scripts = soup.find_all('script')

        # Check for issues
        issues = []
        recommendations = []

        # GitHub Pages compatibility checks
        github_pages_compatible = True

        # Check for server-side code
        if '<?php' in content or '<%' in content:
            issues.append("Contains server-side code (PHP/ASP) - not compatible with GitHub Pages")
            github_pages_compatible = False

        # Check for missing alt attributes
        images_without_alt = [img for img in images if not img.get('alt')]
        if images_without_alt:
            issues.append(f"{len(images_without_alt)} images missing alt attributes")
            recommendations.append("Add alt attributes to all images for accessibility")

        # Check meta description
        if not meta_desc:
            issues.append("Missing meta description")
            recommendations.append("Add meta description for better SEO")
        elif len(meta_desc) > 160:
            issues.append("Meta description too long (>160 characters)")
            recommendations.append("Shorten meta description to 150-160 characters")

        # Check for external scripts that might not work on GitHub Pages
        for script in scripts:
            src = script.get('src', '')
            if 'localhost' in src:
                issues.append("Script references localhost - will break in production")
                github_pages_compatible = False

        # Check for large images (estimate)
        large_images = []
        for img in images:
            src = img.get('src', '')
            if src and not src.startswith('http'):
                img_path = self.docs_dir / src.lstrip('/')
                if img_path.exists():
                    try:
                        with Image.open(img_path) as image:
                            if image.size[0] > 2000 or image.size[1] > 2000:
                                large_images.append(src)
                    except Exception:
                        pass

        if large_images:
            recommendations.append(f"Optimize {len(large_images)} large images for web")

        # Check for performance improvements
        if len(scripts) > 5:
            recommendations.append("Consider minifying or combining JavaScript files")

        if len(links) > 50:
            recommendations.append("Consider pagination or lazy loading for many links")

        return AnalysisResult(
            file_path=str(file_path),
            title=title,
            meta_description=meta_desc,
            image_count=len(images),
            link_count=len(links),
            script_count=len(scripts),
            issues=issues,
            recommendations=recommendations,
            github_pages_compatible=github_pages_compatible
        )

    def analyze_all(self) -> List[AnalysisResult]:
        """Analyze all HTML files in the docs directory."""
        html_files = list(self.docs_dir.glob('*.html'))

        if not html_files:
            print("❌ No HTML files found in docs directory")
            return []

        print(f"📋 Found {len(html_files)} HTML files")

        for file_path in html_files:
            try:
                result = self.analyze_file(file_path)
                self.results.append(result)
            except Exception as e:
                print(f"❌ Error analyzing {file_path}: {e}")

        return self.results

    def generate_report(self, output_file: str = None) -> Dict[str, Any]:
        """Generate a comprehensive analysis report."""
        if not self.results:
            self.analyze_all()

        # Calculate summary statistics
        total_files = len(self.results)
        compatible_files = sum(1 for r in self.results if r.github_pages_compatible)
        total_issues = sum(len(r.issues) for r in self.results)
        total_recommendations = sum(len(r.recommendations) for r in self.results)

        report = {
            "project": "FreshThreads LLC",
            "analysis_date": str(Path.cwd()),
            "summary": {
                "total_files": total_files,
                "github_pages_compatible": compatible_files,
                "compatibility_rate": f"{(compatible_files/total_files)*100:.1f}%" if total_files > 0 else "0%",
                "total_issues": total_issues,
                "total_recommendations": total_recommendations
            },
            "files": []
        }

        for result in self.results:
            report["files"].append({
                "file": result.file_path,
                "title": result.title,
                "meta_description": result.meta_description[:100] + "..." if len(result.meta_description) > 100 else result.meta_description,
                "elements": {
                    "images": result.image_count,
                    "links": result.link_count,
                    "scripts": result.script_count
                },
                "github_pages_compatible": result.github_pages_compatible,
                "issues": result.issues,
                "recommendations": result.recommendations
            })

        if output_file:
            with open(output_file, 'w') as f:
                json.dump(report, f, indent=2)
            print(f"📄 Report saved to {output_file}")

        return report

    def print_summary(self):
        """Print a summary of the analysis."""
        if not self.results:
            print("❌ No analysis results available")
            return

        print("\n🧵 FreshThreads LLC - HTML Analysis Summary")
        print("=" * 50)

        total_files = len(self.results)
        compatible_files = sum(1 for r in self.results if r.github_pages_compatible)
        total_issues = sum(len(r.issues) for r in self.results)

        print(f"📄 Files analyzed: {total_files}")
        print(f"✅ GitHub Pages compatible: {compatible_files}/{total_files}")
        print(f"⚠️  Total issues found: {total_issues}")

        print("\n📋 File Details:")
        for result in self.results:
            status = "✅" if result.github_pages_compatible else "❌"
            print(f"{status} {Path(result.file_path).name}")
            if result.issues:
                for issue in result.issues:
                    print(f"    ⚠️  {issue}")
            if result.recommendations:
                for rec in result.recommendations[:2]:  # Show first 2 recommendations
                    print(f"    💡 {rec}")
                if len(result.recommendations) > 2:
                    print(f"    💡 ... and {len(result.recommendations) - 2} more recommendations")


def main():
    """Main function."""
    parser = argparse.ArgumentParser(description="Analyze HTML files for FreshThreads project")
    parser.add_argument("--docs-dir", default="docs", help="Directory containing HTML files")
    parser.add_argument("--output", help="Output file for JSON report")
    parser.add_argument("--file", help="Analyze specific file instead of all files")
    parser.add_argument("--summary-only", action="store_true", help="Show only summary")

    args = parser.parse_args()

    analyzer = HTMLAnalyzer(args.docs_dir)

    if args.file:
        # Analyze single file
        file_path = Path(args.file)
        if not file_path.exists():
            print(f"❌ File not found: {file_path}")
            sys.exit(1)

        result = analyzer.analyze_file(file_path)
        analyzer.results = [result]
    else:
        # Analyze all files
        analyzer.analyze_all()

    if args.summary_only:
        analyzer.print_summary()
    else:
        report = analyzer.generate_report(args.output)
        analyzer.print_summary()

        if not args.output:
            print(f"\n💡 Use --output report.json to save detailed report")


if __name__ == "__main__":
    main()
