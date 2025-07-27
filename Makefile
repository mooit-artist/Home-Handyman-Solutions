# Home Handyman Solutions LLC - Makefile
# Provides convenient commands for development and local LLM integration

.PHONY: help dev validate format deploy llm-start llm-stop llm-status llm-chat llm-review llm-analyze llm-security llm-improve llm-compat llm-models llm-pull llm-switch llm-tasks python-setup python-install python-activate python-clean python-deps python-status python-shell python-run python-update analyze-html analyze-html-report continue-setup continue-status continue-sync llm-full-setup secrets-get secrets-set secrets-list secrets-delete secrets-export secrets-import secrets-setup security-scan security-test security-auth csp-add csp-check csp-validate csp-report design-analyze design-refactor design-preview design-colors lint lint-html lint-css lint-js lint-json lint-python lint-shell lint-markdown lint-yaml lint-fix clean install

# Default target
help:
	@echo "🔨 Home Handyman Solutions LLC - Development Commands"
	@echo ""
	@echo "📋 Available commands:"
	@echo "  make dev          - Start development server (live-server)"
	@echo "  make validate     - Validate HTML files"
	@echo "  make format       - Format HTML, CSS, and JS files"
	@echo "  make deploy       - Deploy to GitHub Pages"
	@echo ""
	@echo "🤖 Local LLM Commands:"
	@echo "  make llm-start    - Start local LLM server (Ollama)"
	@echo "  make llm-stop     - Stop local LLM server"
	@echo "  make llm-status   - Check LLM server status"
	@echo "  make llm-chat     - Interactive chat with local LLM"
	@echo "  make llm-review   - Review codebase with LLM"
	@echo "  make llm-analyze  - Analyze project structure with LLM"
	@echo "  make llm-security - Security review with LLM"
	@echo "  make llm-improve  - Get improvement suggestions"
	@echo "  make llm-compat   - Check GitHub Pages compatibility"
	@echo "  make llm-models   - List available models"
	@echo "  make llm-tasks    - Show recommended models for tasks"
	@echo "  make llm-pull MODEL=<name> - Pull a specific model"
	@echo "  make llm-switch MODEL=<name> - Switch default model"
	@echo ""
	@echo "🐍 Python Environment Commands:"
	@echo "  make python-setup    - Create Python virtual environment"
	@echo "  make python-install [PACKAGE=name] - Install dependencies or specific package"
	@echo "  make python-activate - Show activation command and status"
	@echo "  make python-deps     - Update requirements.txt"
	@echo "  make python-clean    - Remove Python environment"
	@echo "  make python-status   - Show environment status"
	@echo "  make python-shell    - Start Python shell in environment"
	@echo "  make python-run SCRIPT=<path> - Run Python script"
	@echo "  make python-update   - Update all packages"
	@echo "  make analyze-html    - Analyze HTML files for GitHub Pages compatibility"
	@echo "  make analyze-html-report - Generate detailed HTML analysis report"
	@echo ""
	@echo "🔧 Continue Extension Commands:"
	@echo "  make continue-setup  - Configure Continue extension for local LLM"
	@echo "  make continue-status - Check Continue extension configuration"
	@echo "  make continue-sync   - Sync Continue config with local LLM settings"
	@echo ""
	@echo "🔐 Secrets Management Commands:"
	@echo "  make secrets-get KEY=<key> - Retrieve secret from Keychain"
	@echo "  make secrets-set KEY=<key> - Store secret in Keychain"
	@echo "  make secrets-list    - List stored secrets for this project"
	@echo "  make secrets-delete KEY=<key> - Delete secret from Keychain"
	@echo "  make secrets-export [FILE=path] - Export secrets to .env file"
	@echo "  make secrets-import [FILE=path] - Import secrets from .env file"
	@echo "  make secrets-setup   - Interactive setup for common secrets"
	@echo ""
	@echo "🔒 Security Commands:"
	@echo "  make security-scan   - Run Snyk security scan"
	@echo "  make security-test   - Run comprehensive security tests"
	@echo "  make security-auth   - Authenticate with Snyk"
	@echo ""
	@echo "🛡️  Content Security Policy (CSP) Commands:"
	@echo "  make csp-add         - Add CSP headers to all HTML files"
	@echo "  make csp-check       - Check which files have CSP headers"
	@echo "  make csp-validate    - Validate CSP policy syntax"
	@echo "  make csp-report      - Generate CSP compliance report"
	@echo ""
	@echo "🔧 Apache .htaccess Commands:"
	@echo "  make htaccess-check  - Test .htaccess syntax and rules"
	@echo "  make htaccess-backup - Backup current .htaccess file"
	@echo ""
	@echo "🎨 Design & LLM-Assisted Refactoring Commands:"
	@echo "  make design-analyze  - Analyze current design with LLM"
	@echo "  make design-refactor - LLM-assisted design refactoring"
	@echo "  make design-preview  - Preview design changes locally"
	@echo "  make design-colors   - Extract and analyze color palette"
	@echo ""
	@echo "🔍 Linting Commands:"
	@echo "  make lint            - Run all linters"
	@echo "  make lint-html       - Lint HTML files"
	@echo "  make lint-css        - Lint CSS files"
	@echo "  make lint-js         - Lint JavaScript files"
	@echo "  make lint-json       - Lint JSON files"
	@echo "  make lint-python     - Lint Python files"
	@echo "  make lint-shell      - Lint shell scripts"
	@echo "  make lint-markdown   - Lint Markdown files"
	@echo "  make lint-yaml       - Lint YAML files"
	@echo "  make lint-fix        - Auto-fix linting issues where possible"
	@echo ""
	@echo "🧹 Utility Commands:"
	@echo "  make clean        - Clean temporary files"
	@echo "  make install      - Install development dependencies"
	@echo ""
	@echo "🚀 Combined Workflows:"
	@echo "  make llm-full-setup - Complete LLM development environment setup"
	@echo "  make llm-dev      - Start development server with LLM"
	@echo "  make llm-deploy   - LLM-assisted deployment"

# Development commands
dev:
	@echo "🚀 Starting development server..."
	@cd docs && npx live-server --port=5500 --entry-file=index.html --mount=/docs:.

validate:
	@echo "✅ Validating HTML files..."
	@npx html-validate docs/*.html

format:
	@echo "🎨 Formatting code files..."
	@npx prettier --write docs/*.html docs/**/*.css docs/**/*.js

deploy:
	@echo "🚀 Deploying to GitHub Pages..."
	@git add .
	@git status
	@echo "Committing changes..."
	@git commit -m "Update website - $(shell date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit"
	@git push origin main

# Local LLM commands
llm-start:
	@echo "🤖 Starting local LLM server (Ollama)..."
	@if ! command -v ollama >/dev/null 2>&1; then \
		echo "❌ Ollama not found. Please install Ollama first."; \
		echo "   Visit: https://ollama.ai"; \
		exit 1; \
	fi
	@echo "Starting Ollama server..."
	@ollama serve > /dev/null 2>&1 & echo $$! > .ollama.pid
	@sleep 3
	@echo "✅ Ollama server started"
	@echo "📋 Pulling dolphin-llama3 model if needed..."
	@ollama pull dolphin-llama3
	@echo "🎯 LLM server ready at http://localhost:11434"

llm-stop:
	@echo "🛑 Stopping local LLM server..."
	@if [ -f .ollama.pid ]; then \
		kill `cat .ollama.pid` 2>/dev/null || true; \
		rm .ollama.pid; \
		echo "✅ Ollama server stopped"; \
	else \
		echo "⚠️  No running Ollama server found"; \
	fi

llm-status:
	@echo "📊 Checking LLM server status..."
	@if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "✅ Ollama server is running at http://localhost:11434"; \
		echo "📋 Available models:"; \
		curl -s http://localhost:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "  - dolphin-llama3"; \
	else \
		echo "❌ Ollama server is not running"; \
		echo "   Run 'make llm-start' to start the server"; \
	fi

llm-chat:
	@echo "💬 Starting interactive chat with local LLM..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh chat $(MODEL)

llm-review:
	@echo "🔍 Running LLM code review..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh analyze $(FILE) $(MODEL)

llm-analyze:
	@echo "📊 Analyzing project with LLM..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh analyze $(FILE) $(MODEL)

llm-security:
	@echo "🔒 Running security review..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh security $(MODEL)

llm-improve:
	@echo "� Getting improvement suggestions..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh improve

llm-compat:
	@echo "✅ Checking GitHub Pages compatibility..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh compat $(MODEL)

llm-models:
	@echo "📋 Listing available models..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh models

llm-tasks:
	@echo "🎯 Showing recommended models for tasks..."
	@./scripts/llm-helper.sh tasks

llm-pull:
	@if [ -z "$(MODEL)" ]; then \
		echo "❌ No model specified. Usage: make llm-pull MODEL=<model_name>"; \
		echo "Examples:"; \
		echo "  make llm-pull MODEL=codellama:13b"; \
		echo "  make llm-pull MODEL=mistral:7b"; \
		exit 1; \
	fi
	@echo "📥 Pulling model: $(MODEL)..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh pull $(MODEL)

llm-switch:
	@if [ -z "$(MODEL)" ]; then \
		echo "❌ No model specified. Usage: make llm-switch MODEL=<model_name>"; \
		echo "Examples:"; \
		echo "  make llm-switch MODEL=codellama:13b"; \
		echo "  make llm-switch MODEL=mistral:7b"; \
		exit 1; \
	fi
	@echo "🔄 Switching to model: $(MODEL)..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh switch $(MODEL)

# Python Environment Commands
python-setup:
	@echo "🐍 Setting up Python virtual environment..."
	@./scripts/python-env.sh create

python-install:
	@echo "📦 Installing Python dependencies..."
	@if [ -n "$(PACKAGE)" ]; then \
		./scripts/python-env.sh install $(PACKAGE); \
	else \
		./scripts/python-env.sh install; \
	fi

python-activate:
	@./scripts/python-env.sh status

python-deps:
	@echo "📝 Updating requirements.txt..."
	@./scripts/python-env.sh requirements

python-clean:
	@echo "🧹 Cleaning Python environment..."
	@./scripts/python-env.sh clean

python-status:
	@./scripts/python-env.sh status

python-shell:
	@echo "🐍 Starting Python shell in virtual environment..."
	@./scripts/python-env.sh shell

python-run:
	@if [ -z "$(SCRIPT)" ]; then \
		echo "❌ No script specified. Usage: make python-run SCRIPT=<script_path>"; \
		echo "Example: make python-run SCRIPT=scripts/build.py"; \
		exit 1; \
	fi
	@echo "🚀 Running Python script: $(SCRIPT)"
	@./scripts/python-env.sh run $(SCRIPT)

python-update:
	@echo "⬆️  Updating Python packages..."
	@./scripts/python-env.sh update

# Python-based analysis tools
analyze-html:
	@echo "🔍 Analyzing HTML files with Python..."
	@if [ ! -d "venv" ]; then \
		echo "❌ Python environment not found. Run 'make python-setup' first"; \
		exit 1; \
	fi
	@if [ -n "$(FILE)" ]; then \
		./scripts/python-env.sh run scripts/analyze_html.py --file $(FILE); \
	else \
		./scripts/python-env.sh run scripts/analyze_html.py; \
	fi

analyze-html-report:
	@echo "📊 Generating HTML analysis report..."
	@if [ ! -d "venv" ]; then \
		echo "❌ Python environment not found. Run 'make python-setup' first"; \
		exit 1; \
	fi
	@./scripts/python-env.sh run scripts/analyze_html.py --output analysis-report.json
	@echo "✅ Report saved to analysis-report.json"

# Utility commands
clean:
	@echo "🧹 Cleaning temporary files..."
	@rm -f .ollama.pid
	@rm -f /tmp/llm-review.txt
	@rm -f /tmp/llm-analysis.txt
	@rm -f security-report.json
	@rm -f .env.local
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "✅ Cleanup complete"

install:
	@echo "📦 Installing development dependencies..."
	@echo "Installing Node.js dependencies..."
	@npm install
	@echo "Installing system dependencies..."
	@if ! command -v shellcheck >/dev/null 2>&1; then \
		echo "Installing shellcheck..."; \
		if command -v brew >/dev/null 2>&1; then \
			brew install shellcheck; \
		else \
			echo "⚠️  Please install shellcheck manually"; \
		fi; \
	fi
	@if ! command -v yamllint >/dev/null 2>&1; then \
		echo "Installing yamllint..."; \
		pip3 install yamllint; \
	fi
	@if ! command -v ollama >/dev/null 2>&1; then \
		echo "⚠️  Ollama not found. Please install manually:"; \
		echo "   Visit: https://ollama.ai"; \
	else \
		echo "✅ Ollama found"; \
	fi
	@echo "✅ Dependencies installation complete"

# Secrets Management Commands
secrets-get:
	@if [ -z "$(KEY)" ]; then \
		echo "❌ No key specified. Usage: make secrets-get KEY=<key_name>"; \
		echo "Examples:"; \
		echo "  make secrets-get KEY=github-token"; \
		echo "  make secrets-get KEY=api-key"; \
		echo ""; \
		echo "Available secrets:"; \
		./scripts/secrets-manager.sh list; \
		exit 1; \
	fi
	@./scripts/secrets-manager.sh get $(KEY)

secrets-set:
	@if [ -z "$(KEY)" ]; then \
		echo "❌ No key specified. Usage: make secrets-set KEY=<key_name>"; \
		echo "Examples:"; \
		echo "  make secrets-set KEY=github-token"; \
		echo "  make secrets-set KEY=api-key"; \
		exit 1; \
	fi
	@./scripts/secrets-manager.sh set $(KEY) $(VALUE)

secrets-list:
	@./scripts/secrets-manager.sh list

secrets-delete:
	@if [ -z "$(KEY)" ]; then \
		echo "❌ No key specified. Usage: make secrets-delete KEY=<key_name>"; \
		echo "Examples:"; \
		echo "  make secrets-delete KEY=github-token"; \
		echo "  make secrets-delete KEY=old-api-key"; \
		exit 1; \
	fi
	@./scripts/secrets-manager.sh delete $(KEY)

secrets-export:
	@echo "📤 Exporting secrets to .env file..."
	@./scripts/secrets-manager.sh export $(FILE)

secrets-import:
	@echo "📥 Importing secrets from .env file..."
	@./scripts/secrets-manager.sh import $(FILE)

secrets-setup:
	@echo "🔧 Setting up common development secrets..."
	@./scripts/secrets-manager.sh setup

# Security Commands
security-scan:
	@echo "🔒 Running Snyk security scan..."
	@if ! command -v snyk >/dev/null 2>&1; then \
		echo "❌ Snyk not found. Installing..."; \
		npm install -g snyk; \
	fi
	@echo "🔍 Scanning for vulnerabilities..."
	@snyk test --severity-threshold=medium || echo "⚠️  Vulnerabilities found - check output above"

security-test:
	@echo "🔒 Running comprehensive security tests..."
	@if ! command -v snyk >/dev/null 2>&1; then \
		echo "❌ Snyk not found. Installing..."; \
		npm install -g snyk; \
	fi
	@echo "🔍 Testing for known vulnerabilities..."
	@snyk test --json --severity-threshold=low > security-report.json || true
	@echo "🔍 Testing for license issues..."
	@snyk test --print-deps || true
	@echo "🔍 Scanning Docker images (if any)..."
	@if [ -f Dockerfile ]; then snyk test --docker || true; fi
	@echo "✅ Security tests completed. Check security-report.json for details."

security-auth:
	@echo "🔐 Authenticating with Snyk..."
	@if ! command -v snyk >/dev/null 2>&1; then \
		echo "❌ Snyk not found. Installing..."; \
		npm install -g snyk; \
	fi
	@echo "📋 Opening Snyk authentication..."
	@snyk auth
	@echo "✅ Snyk authentication completed"

# Linting Commands
lint:
	@echo "🔍 Running all linters..."
	@make lint-html
	@make lint-css
	@make lint-js
	@make lint-json
	@make lint-python
	@make lint-shell
	@make lint-markdown
	@make lint-yaml
	@echo "✅ All linting completed"

lint-html:
	@echo "🔍 Linting HTML files..."
	@if [ ! -f "package-lock.json" ]; then \
		echo "❌ Dependencies not installed. Run 'npm install' first"; \
		exit 1; \
	fi
	@find . -name "*.html" -not -path "./node_modules/*" -not -path "./venv/*" | xargs npx html-validate || echo "⚠️  HTML validation issues found"

lint-css:
	@echo "🔍 Linting CSS files..."
	@if [ ! -f "package-lock.json" ]; then \
		echo "❌ Dependencies not installed. Run 'npm install' first"; \
		exit 1; \
	fi
	@find . -name "*.css" -not -path "./node_modules/*" -not -path "./venv/*" | xargs npx stylelint --config-basedir . || echo "⚠️  CSS linting issues found"

lint-js:
	@echo "🔍 Linting JavaScript files..."
	@if [ ! -f "package-lock.json" ]; then \
		echo "❌ Dependencies not installed. Run 'npm install' first"; \
		exit 1; \
	fi
	@find . -name "*.js" -not -path "./node_modules/*" -not -path "./venv/*" | xargs npx eslint || echo "⚠️  JavaScript linting issues found"

lint-json:
	@echo "🔍 Linting JSON files..."
	@if [ ! -f "package-lock.json" ]; then \
		echo "❌ Dependencies not installed. Run 'npm install' first"; \
		exit 1; \
	fi
	@find . -name "*.json" -not -path "./node_modules/*" -not -path "./venv/*" -not -path "./.vscode/*" | xargs -I {} sh -c 'echo "Checking {}" && npx jsonlint {} > /dev/null' || echo "⚠️  JSON linting issues found"

lint-python:
	@echo "🔍 Linting Python files..."
	@if [ ! -d "venv" ]; then \
		echo "❌ Python environment not found. Run 'make python-setup' first"; \
		exit 1; \
	fi
	@source venv/bin/activate && python -m pip show flake8 >/dev/null 2>&1 || source venv/bin/activate && python -m pip install flake8
	@find . -name "*.py" -not -path "./venv/*" -exec venv/bin/python -m flake8 --max-line-length=100 --ignore=E203,W503 {} \; || echo "⚠️  Python linting issues found"

lint-shell:
	@echo "🔍 Linting shell scripts..."
	@if ! command -v shellcheck >/dev/null 2>&1; then \
		echo "❌ shellcheck not found. Installing..."; \
		if command -v brew >/dev/null 2>&1; then \
			brew install shellcheck; \
		else \
			echo "⚠️  Please install shellcheck manually"; \
			exit 1; \
		fi; \
	fi
	@find . -name "*.sh" -not -path "./venv/*" | xargs shellcheck || echo "⚠️  Shell script linting issues found"

lint-markdown:
	@echo "🔍 Linting Markdown files..."
	@if [ ! -f "package-lock.json" ]; then \
		echo "❌ Dependencies not installed. Run 'npm install' first"; \
		exit 1; \
	fi
	@find . -name "*.md" -not -path "./node_modules/*" -not -path "./venv/*" | xargs npx markdownlint || echo "⚠️  Markdown linting issues found"

lint-yaml:
	@echo "🔍 Linting YAML files..."
	@if ! command -v yamllint >/dev/null 2>&1 && ! python3 -m yamllint --version >/dev/null 2>&1; then \
		echo "❌ yamllint not found. Installing..."; \
		pip3 install yamllint; \
	fi
	@if command -v yamllint >/dev/null 2>&1; then \
		find . -name "*.yml" -o -name "*.yaml" -not -path "./venv/*" | xargs yamllint || echo "⚠️  YAML linting issues found"; \
	else \
		find . -name "*.yml" -o -name "*.yaml" -not -path "./venv/*" | xargs python3 -m yamllint || echo "⚠️  YAML linting issues found"; \
	fi

lint-fix:
	@echo "🔧 Auto-fixing linting issues..."
	@echo "📝 Formatting Python files with black..."
	@if [ -d "venv" ]; then \
		source venv/bin/activate && python -m pip show black >/dev/null 2>&1 || source venv/bin/activate && python -m pip install black; \
		find . -name "*.py" -not -path "./venv/*" -exec venv/bin/python -m black --line-length=100 {} \;; \
	fi
	@echo "📝 Formatting with prettier..."
	@if [ -f "package-lock.json" ]; then \
		npx prettier --write "docs/**/*.{html,css,js,json,md}" "*.{json,md}" ".github/**/*.{yml,yaml}" || true; \
	fi
	@echo "✅ Auto-fixing completed"

# Continue Extension Configuration
continue-setup:
	@echo "🔧 Configuring Continue extension for local LLM..."
	@./scripts/continue-helper.sh setup

continue-status:
	@echo "📊 Checking Continue extension configuration..."
	@./scripts/continue-helper.sh status

continue-sync:
	@echo "🔄 Syncing Continue config with local LLM settings..."
	@./scripts/continue-helper.sh sync

# Combined workflows
llm-dev:
	@echo "🚀 Starting full development environment with LLM..."
	@make llm-start
	@echo "⏳ Waiting for LLM server to be ready..."
	@sleep 5
	@echo "🌐 Starting development server..."
	@make dev

llm-deploy:
	@echo "🚀 LLM-assisted deployment..."
	@make llm-start
	@echo "🔍 Running pre-deployment review..."
	@make llm-review
	@echo "✅ Validation and formatting..."
	@make validate
	@make format
	@echo "📤 Deploying..."
	@make deploy
	@make llm-stop

llm-full-setup:
	@echo "🛠️  Complete LLM development environment setup..."
	@echo "📦 Installing dependencies..."
	@make install
	@echo "🐍 Setting up Python environment..."
	@make python-setup
	@echo "🤖 Starting LLM server..."
	@make llm-start
	@echo "🔧 Configuring Continue extension..."
	@make continue-setup
	@echo "🔒 Setting up security scanning..."
	@make security-auth
	@echo "✅ Full LLM development environment ready!"
	@echo ""
	@echo "🎯 Quick start guide:"
	@echo "  • Use 'make dev' to start development server"
	@echo "  • Use 'make llm-chat' for AI assistance"
	@echo "  • Use 'make lint' to check code quality"
	@echo "  • Use 'make csp-add' to secure your HTML files"

# Content Security Policy Commands
csp-add:
	@echo "🛡️  Adding CSP headers to HTML files..."
	@python3 scripts/add-csp.py

csp-check:
	@echo "🔍 Checking CSP implementation..."
	@grep -l "Content-Security-Policy" docs/*.html || echo "No CSP headers found"

csp-validate:
	@echo "✅ Validating CSP policy syntax..."
	@python3 -c "import scripts.add_csp; print('CSP policy syntax is valid')" 2>/dev/null || echo "CSP validation requires custom script"

csp-report:
	@echo "📊 Generating comprehensive CSP compliance report..."
	@python3 scripts/csp-validator.py

# Design & LLM-Assisted Refactoring Commands
design-analyze:
	@echo "🎨 Analyzing current design with LLM..."
	@./scripts/llm-design-refactor.sh

design-refactor:
	@echo "🔄 Starting LLM-assisted design refactoring..."
	@echo "🎯 Target: Minimalistic black & white design based on logo"
	@echo "📁 New design system: docs/styles/minimalistic.css"
	@echo "🔍 Run 'make design-preview' to see changes"
	@echo "💡 Next: Update HTML files to use new CSS classes"

design-preview:
	@echo "👀 Starting design preview server..."
	@echo "🌐 Preview URL: http://localhost:5500"
	@echo "📱 Test the new minimalistic design"
	@make dev

design-colors:
	@echo "🎨 Analyzing logo colors and design palette..."
	@echo "📍 Logo location: docs/assets/handyman-logo.png (or use favicon colors)"
	@echo "🔤 Primary colors: Dark Brown (#3c2e26), Gold (#d4af37)"
	@echo "📊 Color palette: Browns, golds, professional contractor colors"
	@echo "✨ Design system ready in: docs/styles/minimalistic.css"

# Apache .htaccess Commands
htaccess-check:
	@echo "🔧 Testing .htaccess syntax and configuration..."
	@if [ -f "docs/.htaccess" ]; then \
		echo "✅ .htaccess file exists at docs/.htaccess"; \
		echo "📝 File size: $$(wc -c < docs/.htaccess) bytes"; \
		echo "📋 Content preview:"; \
		head -10 docs/.htaccess; \
		echo "..."; \
		echo "🔍 Checking for common Apache modules..."; \
		if grep -q "mod_rewrite" docs/.htaccess; then echo "✅ mod_rewrite rules found"; fi; \
		if grep -q "mod_headers" docs/.htaccess; then echo "✅ mod_headers directives found"; fi; \
		if grep -q "mod_deflate" docs/.htaccess; then echo "✅ mod_deflate compression found"; fi; \
		if grep -q "mod_expires" docs/.htaccess; then echo "✅ mod_expires caching found"; fi; \
		echo "🌐 Testing with local development server..."; \
		echo "   Run 'make dev' to test .htaccess rules locally"; \
	else \
		echo "❌ .htaccess file not found at docs/.htaccess"; \
		echo "   Run this command to create one with professional handyman configurations"; \
	fi

htaccess-backup:
	@echo "💾 Creating backup of .htaccess file..."
	@if [ -f "docs/.htaccess" ]; then \
		cp docs/.htaccess docs/.htaccess.backup-$$(date +%Y%m%d-%H%M%S); \
		echo "✅ Backup created: docs/.htaccess.backup-$$(date +%Y%m%d-%H%M%S)"; \
	else \
		echo "❌ No .htaccess file found to backup"; \
	fi
