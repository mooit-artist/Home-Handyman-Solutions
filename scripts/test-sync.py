# Gallery Sync Test Script
# Quick test to verify Google Drive API connection and folder structure

import os
import sys
from pathlib import Path

# Add parent directory to path to import sync module
sys.path.append(str(Path(__file__).parent))

try:
    # Import the sync module - will be named sync-gallery.py
    import importlib.util
    sync_file = Path(__file__).parent / "sync-gallery.py"
    spec = importlib.util.spec_from_file_location("sync_gallery", sync_file)
    if spec and spec.loader:
        sync_gallery = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(sync_gallery)
        GallerySync = sync_gallery.GallerySync
    else:
        raise ImportError("Could not load sync-gallery.py module")

    def test_connection():
        """Test Google Drive API connection and folder discovery."""
        print("🔍 Testing Google Drive connection...")

        try:
            sync = GallerySync()
            print("✅ Google Drive authentication successful")

            # Get main folder
            main_folder_id = sync.get_drive_folder_id()
            print(f"📁 Main folder ID: {main_folder_id}")

            # List category folders
            print("\n🔍 Discovering category folders...")
            category_folders = sync.list_folders(main_folder_id)

            if category_folders:
                print("✅ Found category folders:")
                for category, folder_id in category_folders.items():
                    print(f"   📂 {category}: {folder_id}")

                    # Count images in each folder
                    images = sync.list_images(folder_id)
                    print(f"      📸 {len(images)} images found")
            else:
                print("⚠️  No category folders found")
                print("   Make sure your Google Drive has folders named:")
                print("   - drywall, deck, electrical, bathroom, painting")

            print("\n✅ Connection test completed successfully!")
            return True

        except (OSError, ValueError, ImportError) as e:
            print(f"❌ Test failed: {e}")
            return False

    def test_local_setup():
        """Test local environment setup."""
        print("\n🔧 Testing local setup...")

        # Check service account file
        if Path('service-account.json').exists():
            print("✅ Service account file found")
        else:
            print("❌ service-account.json not found")
            print("   Download from Google Cloud Console")

        # Check environment variables
        if os.getenv('GOOGLE_DRIVE_FOLDER_ID'):
            print("✅ GOOGLE_DRIVE_FOLDER_ID set")
        else:
            print("⚠️  GOOGLE_DRIVE_FOLDER_ID not set")
            print("   Add to .env file or environment")

        # Check gallery directory
        gallery_dir = Path('docs/gallery/images')
        if gallery_dir.exists():
            print("✅ Gallery directory exists")
            categories = [d.name for d in gallery_dir.iterdir() if d.is_dir()]
            print(f"   📂 Categories: {', '.join(categories)}")
        else:
            print("❌ Gallery directory not found")

    if __name__ == "__main__":
        print("🚀 Gallery Sync Test\n")

        test_local_setup()

        # Only test connection if basic setup looks good
        if Path('service-account.json').exists() and os.getenv('GOOGLE_DRIVE_FOLDER_ID'):
            test_connection()
        else:
            print("\n⚠️  Skipping connection test - setup incomplete")
            print("   Complete local setup first")

except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Install dependencies: pip install -r requirements.txt")
