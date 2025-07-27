#!/bin/bash

# FreshThreads LLC - LLM Integration Script
# Advanced local LLM operations for codebase analysis

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LLM_URL="http://localhost:11434"
DEFAULT_MODEL="dolphin-llama3"
PROJECT_NAME="FreshThreads LLC"
MANIFEST_PATH=".vscode/project-manifest.json"
CONFIG_PATH=".vscode/local-llm-config.json"

# Function to get model for specific tasks
get_task_model() {
    local task="$1"
    case "$task" in
        "code-review") echo "dolphin-llama3" ;;
        "security") echo "llama3:8b" ;;
        "analysis") echo "codellama:13b" ;;
        "chat") echo "dolphin-llama3" ;;
        "improve") echo "dolphin-llama3" ;;
        "compat") echo "llama3:8b" ;;
        "documentation") echo "codellama:7b" ;;
        *) echo "dolphin-llama3" ;;
    esac
}

# Model descriptions function
get_model_description() {
    local model="$1"
    case "$model" in
        "dolphin-llama3") echo "General purpose, good for web development and design" ;;
        "llama3:8b") echo "Balanced model for analysis and security reviews" ;;
        "llama3:13b") echo "Larger model for complex analysis" ;;
        "codellama:7b") echo "Specialized for code analysis and documentation" ;;
        "codellama:13b") echo "Advanced code analysis and architecture review" ;;
        "mistral:7b") echo "Fast responses for quick tasks" ;;
        "mixtral:8x7b") echo "High quality for complex reasoning" ;;
        *) echo "No description available" ;;
    esac
}

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

check_llm_server() {
    if ! curl -s "${LLM_URL}/api/tags" >/dev/null 2>&1; then
        log_error "LLM server not running at ${LLM_URL}"
        log_info "Run 'make llm-start' to start the server"
        exit 1
    fi
}

# Model management functions
get_model_for_task() {
    local task="$1"
    local custom_model="$2"

    if [[ -n "$custom_model" ]]; then
        echo "$custom_model"
    else
        local task_model=$(get_task_model "$task")
        if [[ "$task_model" != "dolphin-llama3" || "$task" == "chat" || "$task" == "improve" || "$task" == "code-review" ]]; then
            echo "$task_model"
        else
            echo "$DEFAULT_MODEL"
        fi
    fi
}

list_available_models() {
    log_info "Checking available models..."
    if curl -s "${LLM_URL}/api/tags" >/dev/null 2>&1; then
        echo "📋 Available models:"
        curl -s "${LLM_URL}/api/tags" | jq -r '.models[].name' 2>/dev/null | while read -r model; do
            local description=$(get_model_description "$model")
            if [[ "$description" != "No description available" ]]; then
                echo "  ✅ $model - $description"
            else
                echo "  ✅ $model"
            fi
        done
    else
        log_error "Cannot connect to LLM server"
        return 1
    fi
}

pull_model() {
    local model="$1"
    if [[ -z "$model" ]]; then
        log_error "No model specified"
        return 1
    fi

    log_info "Pulling model: $model"
    if ollama pull "$model"; then
        log_success "Model $model pulled successfully"
    else
        log_error "Failed to pull model $model"
        return 1
    fi
}

switch_model() {
    local new_model="$1"
    if [[ -z "$new_model" ]]; then
        log_error "No model specified"
        echo "Usage: switch_model <model_name>"
        return 1
    fi

    log_info "Switching to model: $new_model"

    # Check if model exists
    if ! ollama list | grep -q "$new_model"; then
        log_warning "Model $new_model not found locally. Pulling..."
        pull_model "$new_model"
    fi

    # Update the default model temporarily
    DEFAULT_MODEL="$new_model"
    log_success "Switched to model: $new_model"
}

show_task_models() {
    echo "🎯 Recommended models for tasks:"
    local tasks="code-review security analysis chat improve compat documentation"
    for task in $tasks; do
        local model=$(get_task_model "$task")
        echo "  $task: $model"
    done
}

# Function to query LLM with context
query_llm() {
    local prompt="$1"
    local context="$2"
    local task="${3:-chat}"
    local custom_model="$4"

    local model=$(get_model_for_task "$task" "$custom_model")

    log_info "Using model: $model for task: $task"

    # Check if model is available locally
    if ! ollama list | grep -q "$model"; then
        log_warning "Model $model not found locally. Pulling..."
        pull_model "$model"
    fi

    local full_prompt="Context: You are analyzing the ${PROJECT_NAME} project, a print-on-demand e-commerce website deployed on GitHub Pages (static hosting only).

Project constraints:
- Static hosting only (no server-side languages)
- Client-side JavaScript, HTML, CSS only
- No backend databases or server-side processing
- Must use third-party services for dynamic functionality

${context}

Query: ${prompt}"

    echo "$full_prompt" | ollama run "$model" 2>/dev/null
}

# Main functions
analyze_file() {
    local file="$1"
    local custom_model="$2"
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        exit 1
    fi

    log_info "Analyzing file: $file"
    check_llm_server

    local file_content=$(cat "$file")
    local file_type=$(echo "$file" | grep -o '\.[^.]*$' | sed 's/\.//')

    local context="File: $file
File type: $file_type
Content:
$file_content"

    query_llm "Please analyze this file for code quality, GitHub Pages compatibility, security considerations, and improvement suggestions. Focus on clean, minimalistic design principles." "$context" "code-review" "$custom_model"
}

analyze_structure() {
    local custom_model="$1"
    log_info "Analyzing project structure..."
    check_llm_server

    local structure=$(find docs -type f -name "*.html" -o -name "*.css" -o -name "*.js" | sort)
    local manifest_content=""

    if [[ -f "$MANIFEST_PATH" ]]; then
        manifest_content=$(cat "$MANIFEST_PATH")
    fi

    local context="Project structure:
$structure

Project manifest:
$manifest_content"

    query_llm "Analyze this project structure for organization, GitHub Pages optimization, and architectural improvements. Consider the print-on-demand e-commerce context." "$context" "analysis" "$custom_model"
}

review_security() {
    local custom_model="$1"
    log_info "Running security review..."
    check_llm_server

    local security_files=$(find docs -name "*.html" -o -name "*.js" | xargs grep -l "auth\|login\|password\|token\|api" 2>/dev/null || echo "No security-related files found")

    local context="Security analysis for static site:
Files with potential security concerns:
$security_files

Constraints: GitHub Pages static hosting - no server-side security possible."

    query_llm "Review this project for client-side security best practices, considering GitHub Pages limitations. Focus on XSS prevention, secure API integration, and authentication patterns suitable for static sites." "$context" "security" "$custom_model"
}

suggest_improvements() {
    local custom_model="$1"
    log_info "Generating improvement suggestions..."
    check_llm_server

    local readme_content=""
    if [[ -f "README.md" ]]; then
        readme_content=$(head -50 README.md)
    fi

    local context="Project README excerpt:
$readme_content

Current VS Code tasks available:
- Start Live Server
- Validate HTML
- Format HTML Files
- Deploy to GitHub Pages"

    query_llm "Based on this FreshThreads e-commerce project, suggest specific improvements for: 1) User experience, 2) Performance optimization, 3) GitHub Pages optimization, 4) E-commerce functionality within static hosting constraints, 5) SEO and social media integration." "$context" "improve" "$custom_model"
}

check_github_pages_compatibility() {
    local custom_model="$1"
    log_info "Checking GitHub Pages compatibility..."
    check_llm_server

    local problematic_files=$(find docs -name "*.php" -o -name "*.py" -o -name "*.rb" -o -name "*.jsp" 2>/dev/null || echo "")
    local large_files=$(find docs -size +50M 2>/dev/null || echo "")

    local context="Compatibility check:
Potentially problematic files (server-side): $problematic_files
Large files (>50MB): $large_files
Repository structure: Static files in /docs/ directory"

    query_llm "Check this project for GitHub Pages compatibility issues and suggest solutions. Focus on static hosting requirements and file organization best practices." "$context" "compat" "$custom_model"
}

interactive_chat() {
    local custom_model="$1"
    log_info "Starting interactive LLM chat session..."
    log_info "Type 'exit' to quit, or use these commands:"
    echo "  /analyze [file] [model] - Analyze specific file"
    echo "  /structure [model]      - Analyze project structure"
    echo "  /security [model]       - Security review"
    echo "  /improve [model]        - Improvement suggestions"
    echo "  /compat [model]         - GitHub Pages compatibility check"
    echo "  /models                 - List available models"
    echo "  /switch <model>         - Switch default model"
    echo "  /tasks                  - Show recommended models for tasks"
    echo "  /pull <model>           - Pull a new model"
    echo ""

    check_llm_server

    local current_model=$(get_model_for_task "chat" "$custom_model")
    log_info "Current model: $current_model"

    while true; do
        echo -n "🤖 FreshThreads LLM> "
        read -r input

        case "$input" in
            "exit"|"quit"|"/exit"|"/quit")
                log_success "Goodbye!"
                break
                ;;
            "/analyze "*)
                params=(${input#/analyze })
                file="${params[0]}"
                model="${params[1]}"
                analyze_file "$file" "$model"
                ;;
            "/structure"*)
                params=(${input#/structure })
                model="${params[0]}"
                analyze_structure "$model"
                ;;
            "/security"*)
                params=(${input#/security })
                model="${params[0]}"
                review_security "$model"
                ;;
            "/improve"*)
                params=(${input#/improve })
                model="${params[0]}"
                suggest_improvements "$model"
                ;;
            "/compat"*)
                params=(${input#/compat })
                model="${params[0]}"
                check_github_pages_compatibility "$model"
                ;;
            "/models")
                list_available_models
                ;;
            "/switch "*)
                new_model="${input#/switch }"
                switch_model "$new_model"
                current_model="$new_model"
                ;;
            "/tasks")
                show_task_models
                ;;
            "/pull "*)
                model="${input#/pull }"
                pull_model "$model"
                ;;
            "")
                continue
                ;;
            *)
                query_llm "$input" "Interactive session for FreshThreads LLC project development." "chat" "$current_model"
                ;;
        esac
        echo ""
    done
}

# Main command handler
case "$1" in
    "analyze")
        if [[ -z "$2" ]]; then
            analyze_structure "$3"
        else
            analyze_file "$2" "$3"
        fi
        ;;
    "security")
        review_security "$2"
        ;;
    "improve")
        suggest_improvements "$2"
        ;;
    "compat")
        check_github_pages_compatibility "$2"
        ;;
    "chat")
        interactive_chat "$2"
        ;;
    "models")
        list_available_models
        ;;
    "pull")
        if [[ -z "$2" ]]; then
            log_error "No model specified"
            echo "Usage: $0 pull <model_name>"
            exit 1
        fi
        pull_model "$2"
        ;;
    "switch")
        if [[ -z "$2" ]]; then
            log_error "No model specified"
            echo "Usage: $0 switch <model_name>"
            exit 1
        fi
        switch_model "$2"
        ;;
    "tasks")
        show_task_models
        ;;
    *)
        echo "🧵 FreshThreads LLC - LLM Integration Script"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  analyze [file] [model]  - Analyze project structure or specific file"
        echo "  security [model]        - Run security review"
        echo "  improve [model]         - Generate improvement suggestions"
        echo "  compat [model]          - Check GitHub Pages compatibility"
        echo "  chat [model]            - Interactive chat session"
        echo "  models                  - List available models"
        echo "  pull <model>            - Pull a new model"
        echo "  switch <model>          - Switch default model"
        echo "  tasks                   - Show recommended models for tasks"
        echo ""
        echo "Examples:"
        echo "  $0 analyze docs/index.html codellama:7b"
        echo "  $0 security llama3:8b"
        echo "  $0 chat dolphin-llama3"
        echo "  $0 pull mistral:7b"
        ;;
esac
