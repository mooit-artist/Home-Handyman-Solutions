#!/bin/bash

# FreshThreads LLC - Secrets Management Script
# Secure storage and retrieval of secrets using macOS Keychain

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="FreshThreads LLC"
KEYCHAIN_SERVICE="freshthreads-dev"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_secret() {
    echo -e "${PURPLE}🔐 $1${NC}"
}

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script requires macOS (for Keychain access)"
        exit 1
    fi
}

validate_key() {
    local key="$1"
    if [[ -z "$key" ]]; then
        log_error "Key cannot be empty"
        return 1
    fi

    # Validate key format (alphanumeric, dashes, underscores only)
    if [[ ! "$key" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Key must contain only letters, numbers, dashes, and underscores"
        return 1
    fi

    return 0
}

get_secret() {
    local key="$1"

    if ! validate_key "$key"; then
        return 1
    fi

    log_info "Retrieving secret for key: $key"

    # Try to get the secret from Keychain
    local secret
    if secret=$(security find-generic-password -a "$key" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null); then
        echo "$secret"
        log_success "Secret retrieved successfully"
        return 0
    else
        log_error "Secret not found for key: $key"
        log_info "Available keys:"
        list_secrets_quiet
        return 1
    fi
}

set_secret() {
    local key="$1"
    local value="$2"

    if ! validate_key "$key"; then
        return 1
    fi

    # If value not provided, prompt for it
    if [[ -z "$value" ]]; then
        echo -n "Enter secret value for '$key': "
        read -s value
        echo

        if [[ -z "$value" ]]; then
            log_error "Secret value cannot be empty"
            return 1
        fi
    fi

    log_info "Storing secret for key: $key"

    # Check if secret already exists
    if security find-generic-password -a "$key" -s "$KEYCHAIN_SERVICE" >/dev/null 2>&1; then
        log_warning "Secret already exists for key: $key"
        echo -n "Do you want to update it? (y/N): "
        read -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Operation cancelled"
            return 0
        fi

        # Delete existing secret
        security delete-generic-password -a "$key" -s "$KEYCHAIN_SERVICE" 2>/dev/null || true
    fi

    # Add the secret to Keychain
    if security add-generic-password -a "$key" -s "$KEYCHAIN_SERVICE" -w "$value" -T "" 2>/dev/null; then
        log_success "Secret stored successfully for key: $key"

        # Set access control for the secret
        security set-generic-password-partition-list -S apple-tool:,apple: -a "$key" -s "$KEYCHAIN_SERVICE" >/dev/null 2>&1 || true

        return 0
    else
        log_error "Failed to store secret for key: $key"
        return 1
    fi
}

list_secrets() {
    log_info "Listing secrets for $PROJECT_NAME"
    echo "🔐 Stored secrets in service: $KEYCHAIN_SERVICE"
    echo "================================================"

    # Get all secrets for our service
    local secrets
    if secrets=$(security dump-keychain -d 2>/dev/null | grep -A 1 -B 1 "$KEYCHAIN_SERVICE" | grep "acct" | cut -d'"' -f4 | sort -u 2>/dev/null); then
        if [[ -n "$secrets" ]]; then
            echo "$secrets" | while read -r key; do
                if [[ -n "$key" ]]; then
                    local created
                    created=$(security find-generic-password -a "$key" -s "$KEYCHAIN_SERVICE" 2>/dev/null | grep "cdat" | cut -d'"' -f4 || echo "Unknown")
                    echo "🔑 $key (created: $created)"
                fi
            done
        else
            log_warning "No secrets found for this project"
        fi
    else
        log_warning "No secrets found for this project"
    fi

    echo ""
    log_info "Use 'make secrets-get KEY=<key>' to retrieve a specific secret"
}

list_secrets_quiet() {
    # Quiet version for error messages
    local secrets
    if secrets=$(security dump-keychain -d 2>/dev/null | grep -A 1 -B 1 "$KEYCHAIN_SERVICE" | grep "acct" | cut -d'"' -f4 | sort -u 2>/dev/null); then
        if [[ -n "$secrets" ]]; then
            echo "$secrets" | while read -r key; do
                if [[ -n "$key" ]]; then
                    echo "  - $key"
                fi
            done
        else
            echo "  (none)"
        fi
    else
        echo "  (none)"
    fi
}

delete_secret() {
    local key="$1"

    if ! validate_key "$key"; then
        return 1
    fi

    log_info "Deleting secret for key: $key"

    # Check if secret exists
    if ! security find-generic-password -a "$key" -s "$KEYCHAIN_SERVICE" >/dev/null 2>&1; then
        log_error "Secret not found for key: $key"
        return 1
    fi

    # Confirm deletion
    log_warning "This will permanently delete the secret for key: $key"
    echo -n "Are you sure? (y/N): "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled"
        return 0
    fi

    # Delete the secret
    if security delete-generic-password -a "$key" -s "$KEYCHAIN_SERVICE" 2>/dev/null; then
        log_success "Secret deleted successfully for key: $key"
        return 0
    else
        log_error "Failed to delete secret for key: $key"
        return 1
    fi
}

export_secrets() {
    local output_file="$1"

    if [[ -z "$output_file" ]]; then
        output_file=".env.local"
    fi

    log_info "Exporting secrets to $output_file"

    # Create a temporary .env file
    local temp_file
    temp_file=$(mktemp)

    echo "# FreshThreads LLC - Environment Variables" > "$temp_file"
    echo "# Generated on $(date)" >> "$temp_file"
    echo "# DO NOT COMMIT THIS FILE TO VERSION CONTROL" >> "$temp_file"
    echo "" >> "$temp_file"

    # Get all secrets for our service
    local secrets
    if secrets=$(security dump-keychain -d 2>/dev/null | grep -A 1 -B 1 "$KEYCHAIN_SERVICE" | grep "acct" | cut -d'"' -f4 | sort -u 2>/dev/null); then
        if [[ -n "$secrets" ]]; then
            echo "$secrets" | while read -r key; do
                if [[ -n "$key" ]]; then
                    local value
                    if value=$(security find-generic-password -a "$key" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null); then
                        # Convert key to uppercase and replace dashes with underscores
                        local env_key
                        env_key=$(echo "$key" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
                        echo "${env_key}=\"${value}\"" >> "$temp_file"
                    fi
                fi
            done

            mv "$temp_file" "$output_file"
            log_success "Secrets exported to $output_file"
            log_warning "Remember to add $output_file to your .gitignore!"
        else
            log_warning "No secrets found to export"
            rm "$temp_file"
        fi
    else
        log_warning "No secrets found to export"
        rm "$temp_file"
    fi
}

import_secrets() {
    local input_file="$1"

    if [[ -z "$input_file" ]]; then
        input_file=".env.local"
    fi

    if [[ ! -f "$input_file" ]]; then
        log_error "File not found: $input_file"
        return 1
    fi

    log_info "Importing secrets from $input_file"

    # Read the .env file and import secrets
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
            continue
        fi

        # Parse KEY=VALUE format
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"

            # Remove quotes from value
            value=$(echo "$value" | sed 's/^["'\'']*//;s/["'\'']*$//')

            # Convert to lowercase and replace underscores with dashes
            key=$(echo "$key" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

            if validate_key "$key" && [[ -n "$value" ]]; then
                log_info "Importing secret: $key"
                if set_secret "$key" "$value"; then
                    log_success "Imported: $key"
                else
                    log_error "Failed to import: $key"
                fi
            fi
        fi
    done < "$input_file"

    log_success "Import completed"
}

# Command-specific functions for common use cases
setup_common_secrets() {
    log_info "Setting up common development secrets for $PROJECT_NAME"
    echo ""
    log_info "This will help you store commonly used secrets:"
    echo ""

    # List of common secrets for web development
    local common_keys=(
        "github-token:GitHub Personal Access Token"
        "openai-api-key:OpenAI API Key"
        "stripe-secret-key:Stripe Secret Key"
        "stripe-publishable-key:Stripe Publishable Key"
        "firebase-api-key:Firebase API Key"
        "google-analytics-id:Google Analytics ID"
        "sentry-dsn:Sentry DSN"
        "webhook-secret:Webhook Secret"
    )

    for item in "${common_keys[@]}"; do
        local key="${item%%:*}"
        local description="${item#*:}"

        echo -n "Do you want to set up '$description' ($key)? (y/N): "
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -n "Enter value for $description: "
            read -s value
            echo
            if [[ -n "$value" ]]; then
                set_secret "$key" "$value"
            else
                log_warning "Skipping empty value for $key"
            fi
        fi
        echo
    done

    log_success "Common secrets setup completed"
}

# Main command handler
check_macos

case "$1" in
    "get")
        get_secret "$2"
        ;;
    "set")
        set_secret "$2" "$3"
        ;;
    "list")
        list_secrets
        ;;
    "delete")
        delete_secret "$2"
        ;;
    "export")
        export_secrets "$2"
        ;;
    "import")
        import_secrets "$2"
        ;;
    "setup")
        setup_common_secrets
        ;;
    *)
        echo "🔐 FreshThreads LLC - Secrets Management"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  get <key>           - Retrieve secret value"
        echo "  set <key> [value]   - Store secret (prompts if no value given)"
        echo "  list                - List all stored secrets"
        echo "  delete <key>        - Delete a secret"
        echo "  export [file]       - Export secrets to .env file (default: .env.local)"
        echo "  import [file]       - Import secrets from .env file (default: .env.local)"
        echo "  setup               - Interactive setup for common secrets"
        echo ""
        echo "Examples:"
        echo "  $0 get github-token"
        echo "  $0 set api-key"
        echo "  $0 set webhook-secret mysecretvalue"
        echo "  $0 list"
        echo "  $0 export .env.production"
        echo "  $0 setup"
        echo ""
        echo "Note: Secrets are stored in macOS Keychain under service '$KEYCHAIN_SERVICE'"
        ;;
esac
