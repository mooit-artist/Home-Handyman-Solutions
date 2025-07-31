# Home Handyman Solutions

A professional handyman services website featuring an automated gallery system with Google Drive integration.

## 🏠 Features

- **Professional Service Pages**: Complete information about handyman services
- **Interactive Gallery**: Dynamic project showcase with category filtering
- **Automated Content Management**: Google Drive integration for easy image uploads
- **Responsive Design**: Works perfectly on all devices
- **Fast Performance**: Static HTML/CSS with automated backend sync

## 🚀 Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mooit-artist/Home-Handyman-Solutions.git
   cd Home-Handyman-Solutions
   ```

2. **Open the website**:
   - Open `docs/index.html` in your browser
   - Or deploy to GitHub Pages for live hosting

3. **For gallery automation** (optional):
   - Follow the [Gallery Setup](#-gallery-setup) section below

## 📁 Project Structure

```
docs/
├── index.html              # Homepage
├── services.html           # Services overview
├── gallery.html           # Project gallery
├── contact.html            # Contact information
├── about.html             # About the business
├── styles.css             # Main styling
└── gallery/
    └── images/            # Gallery images by category
        ├── drywall/
        ├── deck/
        ├── electrical/
        ├── bathroom/
        └── painting/

.github/workflows/
└── sync-gallery.yml       # Automated gallery sync

scripts/
├── sync-gallery.py        # Gallery sync script
├── requirements.txt       # Python dependencies
└── config.env            # Configuration template
```

## 🖼️ Gallery Setup

The gallery system uses a hybrid approach: static HTML/CSS for performance with automated Google Drive synchronization for easy content management.

### System Overview

**Two Functions:**
1. **Public Gallery**: Fast-loading static page for customers to view projects
2. **Upload Process**: Secure Google Drive integration for business owner uploads

**Architecture:**
- **Frontend**: Static HTML/CSS gallery with category filtering
- **Backend**: Google Drive for secure image storage
- **Automation**: GitHub Actions syncs Drive content daily

### Setup Instructions

#### 1. Google Drive Setup

1. **Create Main Gallery Folder** in your Google Drive
2. **Create Category Subfolders**:
   ```
   Gallery/
   ├── drywall/
   ├── deck/
   ├── electrical/
   ├── bathroom/
   └── painting/
   ```
3. **Share Folder** with appropriate permissions for uploads

#### 2. Google Cloud Project Setup

1. **Create Google Cloud Project**:
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create new project or select existing one

2. **Enable Google Drive API**:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Google Drive API" and enable it

3. **Create Service Account**:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "Service Account"
   - Give it a name like "gallery-sync"
   - Download the JSON key file

4. **Grant Drive Access**:
   - Share your main Gallery folder with the service account email
   - Give "Viewer" permissions (read-only for security)

#### 3. GitHub Repository Setup

1. **Add Secrets** in GitHub Settings > Secrets and variables > Actions:
   ```
   GOOGLE_SERVICE_ACCOUNT_JSON: [Paste the entire service account JSON content]
   GOOGLE_DRIVE_FOLDER_ID: [Your main gallery folder ID from Drive URL]
   ```

2. **Get Folder ID**:
   - Open your main Gallery folder in Google Drive
   - Copy the ID from the URL: `https://drive.google.com/drive/folders/[FOLDER_ID_HERE]`

#### 4. Local Development Setup

1. **Install Python Dependencies**:
   ```bash
   pip install -r scripts/requirements.txt
   ```

2. **Create Service Account File**:
   - Save your service account JSON as `service-account.json` in project root
   - File is gitignored for security

3. **Configure Environment**:
   - Copy `scripts/config.env` to `.env`
   - Update `GOOGLE_DRIVE_FOLDER_ID` with your folder ID

4. **Test Sync**:
   ```bash
   python scripts/test-sync.py
   ```

### How It Works

**For Customers (Public):**
- Visit the gallery page to view completed projects
- Use category filters to browse specific types of work
- Submit project requests via contact form

**For Business Owner (Upload):**
- Upload project photos directly to Google Drive folders
- Organize by category (drywall, deck, electrical, etc.)
- GitHub Actions automatically syncs new images daily at 6 AM Central

**Automated Sync Process:**
- **Scheduled**: Runs daily via GitHub Actions
- **Manual**: Can be triggered manually from Actions tab
- **Smart Updates**: Only downloads changed/new images
- **Optimization**: Resizes and compresses images automatically
- **Organization**: Maps Drive folders to static gallery categories

## 🔧 Manual Gallery Sync

To force a complete re-sync of all images:

**Via GitHub Actions:**
1. Go to Actions tab in GitHub
2. Select "Sync Gallery from Google Drive"
3. Click "Run workflow"
4. Check "Force complete sync"

**Locally:**
```bash
FORCE_SYNC=true python scripts/sync-gallery.py
```

## 🛠️ Development

### Prerequisites
- Python 3.8+ (for gallery automation)
- Modern web browser
- Git

### Local Setup
1. Clone the repository
2. For basic website: Open `docs/index.html`
3. For gallery automation: Follow Gallery Setup above

### Adding New Content
- **Static content**: Edit HTML files in `docs/`
- **Gallery images**: Upload to Google Drive (auto-syncs)
- **Styling**: Modify `docs/styles.css`

## 📱 Deployment

### GitHub Pages (Recommended)
1. Push to GitHub repository
2. Go to Settings > Pages
3. Set source to "Deploy from a branch"
4. Select `main` branch and `/docs` folder
5. Your site will be available at `https://username.github.io/repository-name`

### Other Hosting
- Upload `docs/` folder contents to any web hosting service
- Ensure `index.html` is set as the default page

## 🐛 Troubleshooting

### Gallery Issues

**Authentication Errors:**
- Check service account JSON is valid
- Verify folder sharing permissions
- Ensure Drive API is enabled

**No Images Syncing:**
- Verify folder ID is correct
- Check folder structure matches expected categories
- Ensure images are in supported formats (JPEG, PNG, WebP)

**GitHub Actions Failing:**
- Check GitHub Secrets are set correctly
- Verify service account JSON format
- Review Actions logs for specific errors

### Website Issues
- Check console for JavaScript errors
- Verify all file paths are correct
- Ensure CSS/JS files are loading properly

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

We welcome contributions to improve our website and services! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- How to report bugs and request features
- Development setup and guidelines
- Pull request process
- Code of conduct

### Quick Contribution Steps
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes and test thoroughly
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request using our template

### Issue Templates
We provide templates for:
- 🐛 **Bug Reports** - Report website issues or broken functionality
- � **Feature Requests** - Suggest new features or enhancements
- ❓ **Questions/Support** - Get help or ask questions

## �📞 Support

For issues or questions:

**Technical Issues:**
1. Check sync status: `docs/gallery/images/sync-status.json`
2. Review GitHub Actions logs for detailed error information
3. Test sync locally first to isolate issues
4. [Open an issue](https://github.com/mooit-artist/Home-Handyman-Solutions/issues/new/choose) using our templates

**Business Inquiries:**
- **Phone**: (402) 555-1234
- **Email**: info@homehandymansolutionsllc.com
- **Website**: https://homehandymansolutionsllc.com

**Billing Questions:**
- **Email**: billing@homehandymansolutionsllc.com
- **Online**: https://homehandymansolutionsllc.com/pay-bill.html
