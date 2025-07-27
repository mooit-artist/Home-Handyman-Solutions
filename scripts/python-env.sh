#!/bin/bash

# FreshThreads LLC - Python Environment Management Script
# Advanced Python virtual environment operations for the project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VENV_DIR="venv"
REQUIREMENTS_FILE="requirements.txt"
PYTHON_VERSION="3.9"
PROJECT_NAME="FreshThreads LLC"

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

check_python() {
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "Python 3 not found. Please install Python 3.9 or later."
        exit 1
    fi

    local python_version=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
    log_info "Found Python $python_version"
}

create_venv() {
    log_info "Creating Python virtual environment..."

    if [[ -d "$VENV_DIR" ]]; then
        log_warning "Virtual environment already exists at $VENV_DIR"
        read -p "Do you want to recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$VENV_DIR"
        else
            log_info "Using existing virtual environment"
            return 0
        fi
    fi

    check_python
    python3 -m venv "$VENV_DIR"
    log_success "Virtual environment created at $VENV_DIR"

    # Upgrade pip
    log_info "Upgrading pip..."
    "$VENV_DIR/bin/pip" install --upgrade pip

    create_requirements_if_missing
    install_dependencies
}

create_requirements_if_missing() {
    if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
        log_info "Creating $REQUIREMENTS_FILE with web development tools..."
        cat > "$REQUIREMENTS_FILE" << EOF
# Web Development and Static Site Tools
beautifulsoup4>=4.12.0    # HTML/XML parsing
requests>=2.31.0          # HTTP library
html5lib>=1.1             # HTML5 parser
cssutils>=2.9.0           # CSS parsing and manipulation
Pillow>=10.0.0            # Image processing
markdown>=3.5.0           # Markdown processing
jinja2>=3.1.0             # Template engine
pyyaml>=6.0               # YAML processing

# Code Quality and Formatting
black>=23.0.0             # Code formatter
flake8>=6.0.0             # Linting
pylint>=2.17.0            # Code analysis
mypy>=1.5.0               # Type checking

# Development Tools
ipython>=8.15.0           # Enhanced Python shell
jupyter>=1.0.0            # Notebook environment
pre-commit>=3.4.0         # Git hooks

# Testing
pytest>=7.4.0            # Testing framework
pytest-cov>=4.1.0        # Coverage plugin

# Static Site Generation (optional)
pelican>=4.8.0            # Static site generator
mkdocs>=1.5.0             # Documentation generator

# Automation and Deployment
fabric>=3.2.0             # Deployment automation
invoke>=2.2.0             # Task runner

# Data and API Tools
python-dotenv>=1.0.0      # Environment variables
click>=8.1.0              # CLI creation
rich>=13.5.0              # Rich text and beautiful formatting
EOF
        log_success "Created $REQUIREMENTS_FILE"
    fi
}

install_dependencies() {
    if [[ ! -d "$VENV_DIR" ]]; then
        log_error "Virtual environment not found. Run 'create' first."
        return 1
    fi

    if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
        create_requirements_if_missing
    fi

    log_info "Installing dependencies from $REQUIREMENTS_FILE..."
    "$VENV_DIR/bin/pip" install -r "$REQUIREMENTS_FILE"
    log_success "Dependencies installed successfully"
}

update_dependencies() {
    if [[ ! -d "$VENV_DIR" ]]; then
        log_error "Virtual environment not found. Run 'create' first."
        return 1
    fi

    log_info "Updating all packages..."
    "$VENV_DIR/bin/pip" list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 "$VENV_DIR/bin/pip" install -U
    log_success "Packages updated"

    update_requirements
}

update_requirements() {
    if [[ ! -d "$VENV_DIR" ]]; then
        log_error "Virtual environment not found. Run 'create' first."
        return 1
    fi

    log_info "Updating $REQUIREMENTS_FILE..."
    "$VENV_DIR/bin/pip" freeze > "$REQUIREMENTS_FILE"
    log_success "Requirements file updated"
}

show_status() {
    echo "🐍 Python Environment Status for $PROJECT_NAME"
    echo "=================================================="

    if [[ -d "$VENV_DIR" ]]; then
        echo "✅ Virtual environment: $VENV_DIR"
        echo "🐍 Python version: $("$VENV_DIR/bin/python" --version)"
        echo "📦 Pip version: $("$VENV_DIR/bin/pip" --version | cut -d' ' -f2)"
        echo "📄 Requirements file: $REQUIREMENTS_FILE"

        local package_count=$("$VENV_DIR/bin/pip" list | wc -l)
        echo "📦 Installed packages: $((package_count - 2))"

        echo ""
        echo "🔧 To activate:"
        echo "   source $VENV_DIR/bin/activate"
        echo ""
        echo "📋 Recent packages:"
        "$VENV_DIR/bin/pip" list | head -10
    else
        echo "❌ No virtual environment found"
        echo "   Run 'python-env create' to set up"
    fi
}

list_packages() {
    if [[ ! -d "$VENV_DIR" ]]; then
        log_error "Virtual environment not found. Run 'create' first."
        return 1
    fi

    echo "📦 Installed packages:"
    "$VENV_DIR/bin/pip" list
}

run_in_env() {
    if [[ ! -d "$VENV_DIR" ]]; then
        log_error "Virtual environment not found. Run 'create' first."
        return 1
    fi

    log_info "Running command in virtual environment: $*"
    "$VENV_DIR/bin/python" "$@"
}

shell_in_env() {
    if [[ ! -d "$VENV_DIR" ]]; then
        log_error "Virtual environment not found. Run 'create' first."
        return 1
    fi

    log_info "Starting Python shell in virtual environment..."
    "$VENV_DIR/bin/python" -c "
import sys
print(f'🐍 Python {sys.version}')
print(f'📂 Virtual environment: $VENV_DIR')
print(f'🎯 Project: $PROJECT_NAME')
print('💡 Import your favorite libraries and start coding!')
print()
"
    "$VENV_DIR/bin/ipython" 2>/dev/null || "$VENV_DIR/bin/python"
}

clean_env() {
    if [[ -d "$VENV_DIR" ]]; then
        log_warning "This will delete the virtual environment at $VENV_DIR"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$VENV_DIR"
            log_success "Virtual environment removed"
        else
            log_info "Aborted"
        fi
    else
        log_warning "No virtual environment found to clean"
    fi
}

install_package() {
    local package="$1"
    if [[ -z "$package" ]]; then
        log_error "No package specified"
        echo "Usage: python-env install <package_name>"
        return 1
    fi

    if [[ ! -d "$VENV_DIR" ]]; then
        log_error "Virtual environment not found. Run 'create' first."
        return 1
    fi

    log_info "Installing package: $package"
    "$VENV_DIR/bin/pip" install "$package"

    log_info "Updating requirements.txt..."
    update_requirements
    log_success "Package $package installed and requirements updated"
}

# Main command handler
case "$1" in
    "create")
        create_venv
        ;;
    "install")
        if [[ -n "$2" ]]; then
            install_package "$2"
        else
            install_dependencies
        fi
        ;;
    "update")
        update_dependencies
        ;;
    "requirements")
        update_requirements
        ;;
    "status")
        show_status
        ;;
    "list")
        list_packages
        ;;
    "run")
        shift
        run_in_env "$@"
        ;;
    "shell")
        shell_in_env
        ;;
    "clean")
        clean_env
        ;;
    *)
        echo "🐍 FreshThreads LLC - Python Environment Management"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  create              - Create virtual environment"
        echo "  install [package]   - Install dependencies or specific package"
        echo "  update              - Update all packages"
        echo "  requirements        - Update requirements.txt"
        echo "  status              - Show environment status"
        echo "  list                - List installed packages"
        echo "  run <script>        - Run Python script in environment"
        echo "  shell               - Start Python shell in environment"
        echo "  clean               - Remove virtual environment"
        echo ""
        echo "Examples:"
        echo "  $0 create"
        echo "  $0 install requests"
        echo "  $0 run scripts/build.py"
        echo "  $0 shell"
        ;;
esac
