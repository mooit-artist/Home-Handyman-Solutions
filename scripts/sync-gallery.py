#!/usr/bin/env python3
"""
Gallery Sync Script - Syncs images from Google Drive to static gallery
This script downloads images from a structured Google Drive folder and
organizes them into the static gallery directory structure.
"""

import os
import sys
import json
import hashlib
from pathlib import Path
from typing import Dict, List, Optional
import logging

# Google Drive API
from google.auth.transport.requests import Request
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload

# Image processing
from PIL import Image
import io
import requests

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class GallerySync:
    def __init__(self):
        """Initialize the Gallery Sync with Google Drive API."""
        self.service = self._authenticate()
        self.gallery_base = Path('docs/gallery/images')
        self.gallery_base.mkdir(parents=True, exist_ok=True)

        # Category mapping: Drive folder name -> Static folder name
        self.categories = {
            'drywall': 'drywall',
            'deck': 'deck',
            'electrical': 'electrical',
            'bathroom': 'bathroom',
            'painting': 'painting'
        }

        # Force sync from environment variable
        self.force_sync = os.getenv('FORCE_SYNC', 'false').lower() == 'true'

    def _authenticate(self):
        """Authenticate with Google Drive API using service account."""
        try:
            # Load service account credentials from file
            creds = service_account.Credentials.from_service_account_file(
                'service-account.json',
                scopes=['https://www.googleapis.com/auth/drive.readonly']
            )
            return build('drive', 'v3', credentials=creds)
        except Exception as e:
            logger.error(f"Authentication failed: {e}")
            sys.exit(1)

    def get_drive_folder_id(self) -> str:
        """Get the main Google Drive folder ID from environment."""
        folder_id = os.getenv('GOOGLE_DRIVE_FOLDER_ID')
        if not folder_id:
            logger.error("GOOGLE_DRIVE_FOLDER_ID environment variable not set")
            sys.exit(1)
        return folder_id

    def list_folders(self, parent_id: str) -> Dict[str, str]:
        """List all folders within a parent folder."""
        try:
            results = self.service.files().list(
                q=f"'{parent_id}' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false",
                fields="files(id, name)"
            ).execute()

            folders = {}
            for folder in results.get('files', []):
                folder_name = folder['name'].lower()
                if folder_name in self.categories:
                    folders[folder_name] = folder['id']
                    logger.info(f"Found category folder: {folder['name']} ({folder['id']})")

            return folders
        except Exception as e:
            logger.error(f"Error listing folders: {e}")
            return {}

    def list_images(self, folder_id: str) -> List[Dict]:
        """List all images in a folder."""
        try:
            # Query for common image types
            image_types = ["'image/jpeg'", "'image/png'", "'image/webp'", "'image/jpg'"]
            mime_query = " or ".join([f"mimeType={t}" for t in image_types])

            results = self.service.files().list(
                q=f"'{folder_id}' in parents and ({mime_query}) and trashed=false",
                fields="files(id, name, mimeType, modifiedTime, size)",
                orderBy="name"
            ).execute()

            return results.get('files', [])
        except Exception as e:
            logger.error(f"Error listing images in folder {folder_id}: {e}")
            return []

    def download_image(self, file_id: str, file_name: str) -> Optional[bytes]:
        """Download an image from Google Drive."""
        try:
            request = self.service.files().get_media(fileId=file_id)
            downloaded = io.BytesIO()
            downloader = MediaIoBaseDownload(downloaded, request)

            done = False
            while done is False:
                _, done = downloader.next_chunk()

            downloaded.seek(0)
            return downloaded.read()
        except Exception as e:
            logger.error(f"Error downloading {file_name}: {e}")
            return None

    def optimize_image(self, image_data: bytes, max_width: int = 1200, quality: int = 85) -> bytes:
        """Optimize image size and quality."""
        try:
            with Image.open(io.BytesIO(image_data)) as img:
                # Convert to RGB if needed (for JPEG)
                if img.mode in ('RGBA', 'LA', 'P'):
                    img = img.convert('RGB')

                # Resize if needed
                if img.width > max_width:
                    ratio = max_width / img.width
                    new_height = int(img.height * ratio)
                    img = img.resize((max_width, new_height), Image.Resampling.LANCZOS)

                # Save optimized
                output = io.BytesIO()
                img.save(output, format='JPEG', quality=quality, optimize=True)
                return output.getvalue()
        except Exception as e:
            logger.error(f"Error optimizing image: {e}")
            return image_data

    def get_file_hash(self, file_path: Path) -> str:
        """Get MD5 hash of a file."""
        if not file_path.exists():
            return ""

        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()

    def get_data_hash(self, data: bytes) -> str:
        """Get MD5 hash of data."""
        return hashlib.md5(data).hexdigest()

    def should_update_file(self, file_path: Path, new_data: bytes) -> bool:
        """Check if file should be updated based on content hash."""
        if self.force_sync:
            return True

        if not file_path.exists():
            return True

        existing_hash = self.get_file_hash(file_path)
        new_hash = self.get_data_hash(new_data)

        return existing_hash != new_hash

    def generate_filename(self, category: str, original_name: str, index: int) -> str:
        """Generate standardized filename for gallery."""
        # Clean the original name
        name_base = Path(original_name).stem
        name_clean = "".join(c for c in name_base if c.isalnum() or c in ('-', '_')).lower()

        # Generate filename: category-description-index.jpg
        if name_clean:
            return f"{category}-{name_clean}-{index}.jpg"
        else:
            return f"{category}-project-{index}.jpg"

    def sync_category(self, category: str, folder_id: str) -> int:
        """Sync all images from a category folder."""
        logger.info(f"Syncing category: {category}")

        # Create category directory
        category_dir = self.gallery_base / category
        category_dir.mkdir(exist_ok=True)

        # Get all images from Drive
        images = self.list_images(folder_id)
        updated_count = 0

        for index, image in enumerate(images, 1):
            logger.info(f"Processing: {image['name']}")

            # Generate local filename
            local_filename = self.generate_filename(category, image['name'], index)
            local_path = category_dir / local_filename

            # Download image
            image_data = self.download_image(image['id'], image['name'])
            if not image_data:
                continue

            # Optimize image
            optimized_data = self.optimize_image(image_data)

            # Check if update needed
            if self.should_update_file(local_path, optimized_data):
                # Save optimized image
                with open(local_path, 'wb') as f:
                    f.write(optimized_data)

                logger.info(f"Updated: {local_path}")
                updated_count += 1
            else:
                logger.info(f"Skipped (no changes): {local_path}")

        logger.info(f"Category {category}: {updated_count} files updated")
        return updated_count

    def cleanup_old_images(self, category: str, current_images: List[str]):
        """Remove images that are no longer in Google Drive."""
        category_dir = self.gallery_base / category
        if not category_dir.exists():
            return

        # Get all existing files
        existing_files = list(category_dir.glob("*.jpg"))

        for file_path in existing_files:
            # If file doesn't match current naming pattern, remove it
            if not any(file_path.name.startswith(f"{category}-") for _ in current_images):
                logger.info(f"Removing old file: {file_path}")
                file_path.unlink()

    def run_sync(self):
        """Main sync process."""
        logger.info("Starting gallery sync from Google Drive")

        # Get main folder ID
        main_folder_id = self.get_drive_folder_id()
        logger.info(f"Main folder ID: {main_folder_id}")

        # Get category folders
        category_folders = self.list_folders(main_folder_id)

        if not category_folders:
            logger.warning("No category folders found in Google Drive")
            return

        total_updated = 0

        # Sync each category
        for category, folder_id in category_folders.items():
            try:
                updated = self.sync_category(category, folder_id)
                total_updated += updated
            except Exception as e:
                logger.error(f"Error syncing category {category}: {e}")

        logger.info(f"Sync complete. Total files updated: {total_updated}")

        # Create status file
        status = {
            "last_sync": "$(date -Iseconds)",
            "categories_synced": len(category_folders),
            "files_updated": total_updated,
            "force_sync": self.force_sync
        }

        with open(self.gallery_base / 'sync-status.json', 'w') as f:
            json.dump(status, f, indent=2)

def main():
    """Main entry point."""
    try:
        sync = GallerySync()
        sync.run_sync()
    except KeyboardInterrupt:
        logger.info("Sync interrupted by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Sync failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
