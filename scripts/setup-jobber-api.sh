#!/bin/bash

# Jobber API Setup Script
# This script helps set up the Jobber API integration for Home Handyman Solutions

echo "🔧 Jobber API Setup for Home Handyman Solutions"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo ""
print_info "This script will help you set up your Jobber API integration."
echo ""

# Check if jobber.params exists
if [ -f "../jobber.params" ]; then
    print_status "Found jobber.params file with credentials"

    # Read credentials
    CLIENT_ID=$(grep "Client-ID=" ../jobber.params | cut -d'=' -f2)
    CLIENT_SECRET=$(grep "Client-Secret=" ../jobber.params | cut -d'=' -f2)

    if [ ! -z "$CLIENT_ID" ] && [ ! -z "$CLIENT_SECRET" ]; then
        print_status "Credentials loaded successfully"
        echo "  Client ID: ${CLIENT_ID:0:8}..."
        echo "  Client Secret: ${CLIENT_SECRET:0:8}..."
    else
        print_error "Could not read credentials from jobber.params"
        exit 1
    fi
else
    print_error "jobber.params file not found!"
    echo ""
    print_info "Please create a jobber.params file with your Jobber API credentials:"
    echo "Client-ID=your-client-id"
    echo "Client-Secret=your-client-secret"
    exit 1
fi

echo ""
print_info "Setting up environment variables..."

# Create .env file if it doesn't exist
if [ ! -f "../.env" ]; then
    cat > ../.env << EOF
# Jobber API Configuration
JOBBER_CLIENT_ID=$CLIENT_ID
JOBBER_CLIENT_SECRET=$CLIENT_SECRET
JOBBER_API_URL=https://api.getjobber.com/api/graphql
JOBBER_OAUTH_URL=https://api.getjobber.com/api/oauth
JOBBER_CLIENT_HUB_URL=https://clienthub.getjobber.com/client_hubs/d050407f-bff1-45f6-8f57-7a3fe3c94330/login/new?source=share_login

# Environment
NODE_ENV=development

# Security
ENCRYPT_TOKENS=false
CSRF_PROTECTION=true

# Rate Limiting
REQUESTS_PER_MINUTE=60
BURST_LIMIT=10

# Website Configuration
WEBSITE_URL=https://homehandymansolutionsllc.com
REDIRECT_URI=https://homehandymansolutionsllc.com/oauth/callback
EOF
    print_status ".env file created"
else
    print_warning ".env file already exists - skipping creation"
fi

echo ""
print_info "Checking Jobber API connection..."

# Test API connection (requires curl)
if command -v curl &> /dev/null; then
    # Test OAuth endpoint
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://api.getjobber.com/api/oauth/authorize?client_id=$CLIENT_ID&response_type=code&scope=read_invoices")

    if [ "$HTTP_STATUS" = "302" ] || [ "$HTTP_STATUS" = "200" ]; then
        print_status "Jobber API endpoint is accessible"
    else
        print_warning "Jobber API endpoint returned status: $HTTP_STATUS"
    fi
else
    print_warning "curl not available - skipping API connection test"
fi

echo ""
print_info "Setting up OAuth callback..."

# Create OAuth callback page
cat > ../docs/oauth-callback.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OAuth Callback - Home Handyman Solutions</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        .callback-container {
            max-width: 600px;
            margin: 2rem auto;
            padding: 2rem;
            text-align: center;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        .spinner {
            border: 4px solid #f3f4f6;
            border-top: 4px solid var(--soft-gold);
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 1rem;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <main>
        <div class="callback-container">
            <div class="spinner"></div>
            <h2>Processing OAuth Callback</h2>
            <p id="status">Authenticating with Jobber...</p>
            <div id="result" style="display: none;"></div>
        </div>
    </main>

    <script src="../scripts/jobber-config.js"></script>
    <script>
        // Handle OAuth callback
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const code = urlParams.get('code');
            const state = urlParams.get('state');
            const error = urlParams.get('error');

            const statusEl = document.getElementById('status');
            const resultEl = document.getElementById('result');

            if (error) {
                statusEl.textContent = 'Authentication failed';
                resultEl.innerHTML = `<p style="color: red;">Error: ${error}</p>`;
                resultEl.style.display = 'block';
                return;
            }

            if (!code) {
                statusEl.textContent = 'No authorization code received';
                resultEl.innerHTML = '<p style="color: red;">Invalid callback - no authorization code</p>';
                resultEl.style.display = 'block';
                return;
            }

            // Process the authorization code
            const config = new JobberConfig();
            config.loadCredentials();

            config.exchangeCodeForToken(code, window.location.origin + '/oauth-callback.html')
                .then(tokenData => {
                    statusEl.textContent = 'Authentication successful!';
                    resultEl.innerHTML = `
                        <p style="color: green;">✅ Successfully authenticated with Jobber</p>
                        <p>You can now close this window and return to the payment page.</p>
                        <button onclick="window.close()" style="
                            background: var(--soft-gold);
                            color: var(--dark-walnut);
                            border: none;
                            padding: 0.75rem 1.5rem;
                            border-radius: 6px;
                            cursor: pointer;
                            font-weight: bold;
                            margin-top: 1rem;
                        ">Close Window</button>
                    `;
                    resultEl.style.display = 'block';

                    // Notify parent window if opened in popup
                    if (window.opener) {
                        window.opener.postMessage({
                            type: 'oauth_success',
                            data: tokenData
                        }, window.location.origin);
                    }
                })
                .catch(error => {
                    console.error('OAuth error:', error);
                    statusEl.textContent = 'Authentication failed';
                    resultEl.innerHTML = `<p style="color: red;">❌ Authentication error: ${error.message}</p>`;
                    resultEl.style.display = 'block';
                });
        });
    </script>
</body>
</html>
EOF

print_status "OAuth callback page created at docs/oauth-callback.html"

echo ""
print_info "Setting up security configuration..."

# Add .env to .gitignore if not already there
if [ -f "../.gitignore" ]; then
    if ! grep -q ".env" ../.gitignore; then
        echo ".env" >> ../.gitignore
        print_status "Added .env to .gitignore"
    else
        print_info ".env already in .gitignore"
    fi

    if ! grep -q "jobber.params" ../.gitignore; then
        echo "jobber.params" >> ../.gitignore
        print_status "Added jobber.params to .gitignore"
    else
        print_info "jobber.params already in .gitignore"
    fi
else
    cat > ../.gitignore << EOF
# Environment variables
.env

# Jobber credentials
jobber.params

# Node modules
node_modules/

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/

# Logs
*.log
EOF
    print_status "Created .gitignore file"
fi

echo ""
print_info "Verifying file structure..."

# Check required files
files_to_check=(
    "../scripts/jobber-config.js"
    "../scripts/jobber-service.js"
    "../scripts/jobber-payment-widget.js"
    "../scripts/jobber-env-config.js"
    "../docs/oauth-callback.html"
    "../docs/pay-bill-api.html"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        print_status "$(basename "$file") exists"
    else
        print_error "Missing file: $(basename "$file")"
    fi
done

echo ""
print_info "Next Steps:"
echo "================================================"
echo ""
echo "1. 🔐 Configure Jobber App Settings:"
echo "   - Log into your Jobber Developer account"
echo "   - Add redirect URI: https://homehandymansolutionsllc.com/oauth-callback.html"
echo "   - Enable required scopes: read_invoices, write_invoices, read_clients, read_payments"
echo ""
echo "2. 🌐 Deploy Updates:"
echo "   - Deploy the new payment page: docs/pay-bill-api.html"
echo "   - Deploy OAuth callback: docs/oauth-callback.html"
echo "   - Deploy all script files in scripts/ directory"
echo ""
echo "3. 🧪 Test Integration:"
echo "   - Test OAuth flow"
echo "   - Test invoice lookup"
echo "   - Test payment processing"
echo ""
echo "4. 🔒 Security Checklist:"
echo "   - Move credentials to environment variables in production"
echo "   - Enable HTTPS on your domain"
echo "   - Configure CSP headers for API domains"
echo "   - Set up proper error logging"
echo ""
echo "5. 📝 Update Website:"
echo "   - Update pay-bill.html to link to pay-bill-api.html"
echo "   - Test all payment flows"
echo "   - Update navigation if needed"
echo ""

print_status "Jobber API setup complete!"
print_info "Check the logs above for any warnings or errors that need attention."
