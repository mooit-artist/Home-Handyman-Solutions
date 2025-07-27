#!/bin/bash

# FreshThreads LLC - Continue Extension Configuration Helper
# Manages Continue extension configuration for local LLM integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTINUE_CONFIG_DIR="$HOME/.continue"
CONTINUE_CONFIG_FILE="$CONTINUE_CONFIG_DIR/config.yaml"
LOCAL_LLM_CONFIG=".vscode/local-llm-config.json"
DEFAULT_MODEL="dolphin-llama3"
DEFAULT_API_URL="http://localhost:11434"

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

check_dependencies() {
    local missing_deps=()

    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_warning "Missing dependencies: ${missing_deps[*]}"
        log_info "Installing missing dependencies..."

        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew >/dev/null 2>&1; then
                brew install jq
            else
                log_error "Homebrew not found. Please install jq manually."
                exit 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y jq
        else
            log_error "Unsupported OS. Please install jq manually."
            exit 1
        fi
    fi
}

get_local_llm_config() {
    local model="$DEFAULT_MODEL"
    local api_url="$DEFAULT_API_URL"

    if [[ -f "$LOCAL_LLM_CONFIG" ]]; then
        model=$(jq -r '.model // "dolphin-llama3"' "$LOCAL_LLM_CONFIG")
        api_url=$(jq -r '.apiUrl // "http://localhost:11434"' "$LOCAL_LLM_CONFIG")
    fi

    echo "$model|$api_url"
}

create_continue_config() {
    local model="$1"
    local api_url="$2"
    local model_title

    # Convert model name to title case
    model_title=$(echo "$model" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')

    mkdir -p "$CONTINUE_CONFIG_DIR"

    cat > "$CONTINUE_CONFIG_FILE" << EOF
models:
  - title: "$model_title"
    provider: "ollama"
    model: "$model"
    apiBase: "$api_url"

tabAutocompleteModel:
  title: "$model_title"
  provider: "ollama"
  model: "$model"
  apiBase: "$api_url"

# Optional: Add more advanced configuration
completionOptions:
  temperature: 0.2
  maxTokens: 1000

# Optional: Add custom prompts
customCommands:
  - name: "explain"
    prompt: "Please explain the following code in detail, focusing on its purpose, how it works, and any potential improvements:"
  - name: "optimize"
    prompt: "Please optimize the following code for better performance, readability, and maintainability:"
  - name: "test"
    prompt: "Please write comprehensive tests for the following code:"
  - name: "document"
    prompt: "Please add comprehensive documentation and comments to the following code:"
EOF

    log_success "Continue configuration created at $CONTINUE_CONFIG_FILE"
}

setup_continue() {
    log_info "Setting up Continue extension configuration..."

    check_dependencies

    if [[ -f "$CONTINUE_CONFIG_FILE" ]]; then
        log_warning "Continue config already exists at $CONTINUE_CONFIG_FILE"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Keeping existing configuration"
            return 0
        fi
    fi

    # Get configuration from local LLM config
    local config_data
    config_data=$(get_local_llm_config)
    local model="${config_data%|*}"
    local api_url="${config_data#*|}"

    log_info "Using model: $model"
    log_info "Using API URL: $api_url"

    create_continue_config "$model" "$api_url"

    log_success "Continue extension configured successfully!"
    log_info "To use Continue:"
    log_info "  1. Ensure Ollama is running: make llm-start"
    log_info "  2. Open VS Code - Continue should connect automatically"
    log_info "  3. Use Cmd+I (Mac) or Ctrl+I for inline editing"
    log_info "  4. Use Cmd+L (Mac) or Ctrl+L for chat sidebar"
    log_info "  5. Use Cmd+Shift+L (Mac) or Ctrl+Shift+L for new chat"
}

sync_continue() {
    log_info "Syncing Continue config with local LLM settings..."

    check_dependencies

    if [[ ! -f "$CONTINUE_CONFIG_FILE" ]]; then
        log_error "Continue config not found. Run setup first."
        exit 1
    fi

    # Get current configuration
    local config_data
    config_data=$(get_local_llm_config)
    local model="${config_data%|*}"
    local api_url="${config_data#*|}"

    log_info "Syncing with model: $model"
    log_info "Syncing with API URL: $api_url"

    create_continue_config "$model" "$api_url"

    log_success "Continue configuration synced!"
}

show_status() {
    log_info "Continue Extension Status"
    echo "=========================="

    if [[ -f "$CONTINUE_CONFIG_FILE" ]]; then
        log_success "Continue config exists at $CONTINUE_CONFIG_FILE"

        echo ""
        echo "📄 Current Configuration:"
        echo "------------------------"

        if command -v jq >/dev/null 2>&1; then
            local model api_url
            model=$(yq eval '.models[0].model' "$CONTINUE_CONFIG_FILE" 2>/dev/null || echo "Unknown")
            api_url=$(yq eval '.models[0].apiBase' "$CONTINUE_CONFIG_FILE" 2>/dev/null || echo "Unknown")

            echo "🤖 Model: $model"
            echo "🌐 API URL: $api_url"
        else
            head -10 "$CONTINUE_CONFIG_FILE"
        fi

        echo ""

        # Check if Ollama is running
        if curl -s "$DEFAULT_API_URL/api/tags" >/dev/null 2>&1; then
            log_success "Ollama server is running"
            echo "📋 Available models:"
            curl -s "$DEFAULT_API_URL/api/tags" | jq -r '.models[].name' 2>/dev/null || echo "  - $DEFAULT_MODEL"
        else
            log_warning "Ollama server is not running"
            log_info "Run 'make llm-start' to start the server"
        fi
    else
        log_error "Continue config not found"
        log_info "Run 'make continue-setup' to create configuration"
    fi
}

backup_config() {
    if [[ -f "$CONTINUE_CONFIG_FILE" ]]; then
        local backup_file="$CONTINUE_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$CONTINUE_CONFIG_FILE" "$backup_file"
        log_success "Configuration backed up to $backup_file"
    fi
}

# Main command handler
case "$1" in
    "setup")
        setup_continue
        ;;
    "sync")
        sync_continue
        ;;
    "status")
        show_status
        ;;
    "backup")
        backup_config
        ;;
    *)
        echo "🔧 Continue Extension Configuration Helper"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  setup   - Create Continue configuration for local LLM"
        echo "  sync    - Sync Continue config with local LLM settings"
        echo "  status  - Show current configuration status"
        echo "  backup  - Backup current configuration"
        echo ""
        echo "Examples:"
        echo "  $0 setup"
        echo "  $0 sync"
        echo "  $0 status"
        ;;
esac
