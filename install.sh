#!/bin/bash

# 🤖 Terminal Power - One-Command Installer
# Transforms your terminal into a cyberpunk AI command center

# Enable strict error handling
set -euo pipefail
IFS=$'\n\t'

# Installation log for debugging
INSTALL_LOG="$HOME/.terminal-power-install.log"
exec 1> >(tee -a "$INSTALL_LOG")
exec 2> >(tee -a "$INSTALL_LOG" >&2)

echo "🤖 Terminal Power - Cyberpunk AI Arsenal Installer"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}🔧 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Cross-platform confirmation function
confirm() {
    local message="$1"
    if command -v gum &> /dev/null; then
        gum confirm "$message"
    else
        echo -n "$message (y/n): "
        read -r response
        [[ "$response" =~ ^[Yy]$ ]]
    fi
}

# Enhanced OS and platform detection
detect_platform() {
    case "$OSTYPE" in
        darwin*)
            PLATFORM="macos"
            PACKAGE_MANAGER="brew"
            ;;
        linux*)
            PLATFORM="linux"
            if command -v apt-get &> /dev/null; then
                PACKAGE_MANAGER="apt"
            elif command -v yum &> /dev/null; then
                PACKAGE_MANAGER="yum"
            elif command -v pacman &> /dev/null; then
                PACKAGE_MANAGER="pacman"
            else
                print_error "Unsupported Linux distribution. Please install manually."
                exit 1
            fi
            ;;
        msys*|cygwin*|mingw*)
            if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
                PLATFORM="wsl"
                PACKAGE_MANAGER="apt"  # Most WSL distros use apt
            else
                print_error "Windows is not directly supported. Please use WSL2."
                exit 1
            fi
            ;;
        *)
            print_error "Unsupported operating system: $OSTYPE"
            exit 1
            ;;
    esac
    
    print_success "Detected platform: $PLATFORM with $PACKAGE_MANAGER"
}

# Check internet connectivity
check_internet() {
    print_step "Checking internet connectivity..."
    if ! curl -s --connect-timeout 10 --max-time 30 https://api.github.com &> /dev/null; then
        print_error "No internet connection. Please check your network and try again."
        exit 1
    fi
    print_success "Internet connection verified"
}

# Enhanced prerequisite checking
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    local missing_deps=()
    
    # Check for package manager
    case "$PACKAGE_MANAGER" in
        brew)
            if ! command -v brew &> /dev/null; then
                print_error "Homebrew is required for macOS. Install from https://brew.sh"
                missing_deps+=("homebrew")
            fi
            ;;
        apt)
            if ! command -v apt-get &> /dev/null; then
                print_error "apt package manager not found"
                missing_deps+=("apt")
            fi
            ;;
        yum)
            if ! command -v yum &> /dev/null; then
                print_error "yum package manager not found"
                missing_deps+=("yum")
            fi
            ;;
        pacman)
            if ! command -v pacman &> /dev/null; then
                print_error "pacman package manager not found"
                missing_deps+=("pacman")
            fi
            ;;
    esac
    
    # Check for Claude Code
    if ! command -v claude &> /dev/null; then
        print_warning "Claude Code not found. Please install from:"
        echo "  https://docs.anthropic.com/claude-code"
        echo ""
        echo "Terminal Power will still install, but MCPs won't work without Claude Code."
        if ! confirm "Continue installation anyway?"; then
            exit 1
        fi
    fi
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    # Check for git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_step "Please install the missing dependencies and run the installer again."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Run platform detection and checks
detect_platform
check_internet
check_prerequisites

# Cross-platform package installation
install_packages() {
    print_step "Installing required packages..."
    
    local packages_to_install=()
    
    case "$PACKAGE_MANAGER" in
        brew)
            local brew_packages=(
                "ffmpeg"    # For voice recording
                "jq"        # For JSON parsing  
                "gh"        # GitHub CLI
                "pipx"      # Python package manager
                "gum"       # Interactive UI
            )
            
            for package in "${brew_packages[@]}"; do
                if ! brew list "$package" &>/dev/null; then
                    packages_to_install+=("$package")
                else
                    print_success "$package already installed"
                fi
            done
            
            if [[ ${#packages_to_install[@]} -gt 0 ]]; then
                print_step "Installing packages: ${packages_to_install[*]}"
                if ! brew install "${packages_to_install[@]}"; then
                    print_error "Failed to install some packages. Please install manually:"
                    printf '%s\n' "${packages_to_install[@]}"
                    exit 1
                fi
            fi
            ;;
            
        apt)
            local apt_packages=(
                "ffmpeg"
                "jq"
                "curl"
                "git"
                "python3-pip"
            )
            
            print_step "Updating package list..."
            sudo apt-get update -qq
            
            for package in "${apt_packages[@]}"; do
                if ! dpkg -l | grep -q "^ii  $package "; then
                    packages_to_install+=("$package")
                else
                    print_success "$package already installed"
                fi
            done
            
            if [[ ${#packages_to_install[@]} -gt 0 ]]; then
                print_step "Installing packages: ${packages_to_install[*]}"
                sudo apt-get install -y "${packages_to_install[@]}"
            fi
            
            # Install GitHub CLI separately (requires special repo)
            if ! command -v gh &> /dev/null; then
                print_step "Installing GitHub CLI..."
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt-get update -qq
                sudo apt-get install gh -y
            fi
            
            # Install pipx
            if ! command -v pipx &> /dev/null; then
                print_step "Installing pipx..."
                python3 -m pip install --user pipx
                python3 -m pipx ensurepath
            fi
            
            # Install gum
            if ! command -v gum &> /dev/null; then
                print_step "Installing gum..."
                sudo mkdir -p /etc/apt/keyrings
                curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
                echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
                sudo apt-get update -qq
                sudo apt-get install gum -y
            fi
            ;;
            
        *)
            print_warning "Automatic package installation not supported for $PACKAGE_MANAGER"
            print_step "Please install these packages manually:"
            echo "  - ffmpeg (audio recording)"
            echo "  - jq (JSON parsing)"
            echo "  - gh (GitHub CLI)"
            echo "  - gum (interactive UI)"
            echo "  - pipx (Python package manager)"
            echo ""
            if ! confirm "Continue with manual installation?"; then
                exit 1
            fi
            ;;
    esac
    
    print_success "Package installation completed"
}

install_packages

# Install Python packages for MCPs
print_step "Installing Python MCP packages..."

python_packages=(
    "markitdown"
    "wcgw"
    "free-will-mcp"
)

for package in "${python_packages[@]}"; do
    if pipx list | grep -q "$package"; then
        print_success "$package already installed"
    else
        print_step "Installing $package..."
        pipx install "$package" || print_warning "Failed to install $package (might not exist yet)"
    fi
done

# Copy configuration files
print_step "Setting up configurations..."

# Backup existing .zshrc
if [[ -f ~/.zshrc ]]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    print_success "Backed up existing .zshrc"
fi

# Add Terminal Power configurations to .zshrc
if ! grep -q "# Terminal Power Configuration" ~/.zshrc; then
    cat configs/zshrc_additions >> ~/.zshrc
    print_success "Added Terminal Power configuration to .zshrc"
else
    print_warning "Terminal Power configuration already exists in .zshrc"
fi

# Copy scripts
print_step "Installing scripts..."

# Make scripts directory in home
mkdir -p ~/bin

# Copy voice, GitHub search, and domain search scripts
cp scripts/voice-to-claude.sh ~/
cp scripts/github-search.sh ~/
cp scripts/porkbun-search.sh ~/
cp scripts/weather-tools.sh ~/
cp scripts/color-tools.sh ~/
cp scripts/mcphelp ~/bin/
chmod +x ~/voice-to-claude.sh ~/github-search.sh ~/porkbun-search.sh ~/weather-tools.sh ~/color-tools.sh ~/bin/mcphelp

print_success "Scripts installed and made executable"

# Configure Claude Code MCPs
print_step "Configuring Claude Code MCPs..."

# Basic MCPs that work without additional setup
basic_mcps=(
    "markitdown-simple markitdown"
    "filesystem npx @modelcontextprotocol/server-filesystem"
    "sequential-thinking mcp-sequentialthinking-tools"
    "macos-automator npx @steipete/macos-automator-mcp"
    "wcgw wcgw_mcp"
    "free-will free-will-mcp"
)

for mcp in "${basic_mcps[@]}"; do
    mcp_name=$(echo $mcp | cut -d' ' -f1)
    mcp_command=$(echo $mcp | cut -d' ' -f2-)
    
    if claude mcp list | grep -q "$mcp_name"; then
        print_success "MCP $mcp_name already configured"
    else
        print_step "Adding MCP $mcp_name..."
        claude mcp add $mcp_name $mcp_command || print_warning "Failed to add $mcp_name"
    fi
done

# API Key Setup
print_step "Setting up API keys..."

echo ""
echo "🔑 API KEY SETUP REQUIRED"
echo "========================="
echo ""
echo "To complete the installation, you need to add API keys to your ~/.zshrc:"
echo ""
echo "Required APIs:"
echo "  • OpenAI API Key - https://platform.openai.com/account/api-keys"
echo "  • Google API Key - https://console.cloud.google.com/apis/credentials"  
echo "  • GitHub Token - https://github.com/settings/tokens"
echo "  • Supabase Token - https://supabase.com/dashboard/account/tokens"
echo ""
echo "Optional APIs (for enhanced features):"
echo "  • Replicate API - https://replicate.com/account/api-tokens"
echo "  • ElevenLabs API - https://elevenlabs.io/app/settings/api-keys"
echo "  • Railway Token - https://railway.app/account/tokens"
echo ""
echo "Example configuration:"
echo 'export OPENAI_API_KEY="sk-..."'
echo 'export GOOGLE_API_KEY="AIzaSy..."'
echo 'export GITHUB_TOKEN="ghp_..."'
echo 'export SUPABASE_ACCESS_TOKEN="sbp_..."'
echo ""

# Test basic functionality
print_step "Testing basic functionality..."

# Test voice script
if [[ -f ~/voice-to-claude.sh ]]; then
    print_success "Voice script installed"
else
    print_error "Voice script missing"
fi

# Test GitHub search script  
if [[ -f ~/github-search.sh ]]; then
    print_success "GitHub search script installed"
else
    print_error "GitHub search script missing"
fi

# Verify installation
verify_installation() {
    print_step "Verifying installation..."
    
    local issues=()
    local warnings=()
    
    # Check core scripts
    [[ -f ~/voice-to-claude.sh ]] || issues+=("Voice script missing")
    [[ -f ~/github-search.sh ]] || issues+=("GitHub search script missing")
    [[ -f ~/porkbun-search.sh ]] || issues+=("Domain search script missing")
    [[ -f ~/bin/mcphelp ]] || issues+=("MCP help script missing")
    
    # Check executability
    [[ -x ~/voice-to-claude.sh ]] || issues+=("Voice script not executable")
    [[ -x ~/github-search.sh ]] || issues+=("GitHub search script not executable")
    [[ -x ~/porkbun-search.sh ]] || issues+=("Domain search script not executable")
    [[ -x ~/bin/mcphelp ]] || issues+=("MCP help script not executable")
    
    # Check aliases in shell config
    if [[ -f ~/.zshrc ]]; then
        grep -q "alias mcp=" ~/.zshrc || warnings+=("MCP aliases not found in .zshrc")
        grep -q "voice" ~/.zshrc || warnings+=("Voice aliases not found in .zshrc")
    else
        issues+=(".zshrc file not found")
    fi
    
    # Check essential commands
    command -v ffmpeg &> /dev/null || warnings+=("ffmpeg not found - voice commands won't work")
    command -v jq &> /dev/null || warnings+=("jq not found - JSON parsing may fail")
    command -v gh &> /dev/null || warnings+=("GitHub CLI not found - code search won't work")
    
    if [[ ${#issues[@]} -gt 0 ]]; then
        print_error "Installation verification failed:"
        printf '  ❌ %s\n' "${issues[@]}"
        echo ""
        echo "Please check the installation log: $INSTALL_LOG"
        exit 1
    fi
    
    if [[ ${#warnings[@]} -gt 0 ]]; then
        print_warning "Installation completed with warnings:"
        printf '  ⚠️  %s\n' "${warnings[@]}"
        echo ""
    fi
    
    print_success "Installation verification passed!"
}

# Run verification
verify_installation

# Final setup instructions with enhanced guidance
echo ""
print_step "🤖 Setting up MCPs and API Packs..."
echo ""

# Auto-install Creative Pack if user wants it
if confirm "Install Creative Pack (weather, colors, QR codes, etc.)?"; then
    echo ""
    print_step "Installing Creative Pack..."
    ~/Terminal_Power/scripts/pack-manager.sh install creative
fi

echo ""

# Auto-configure MCPs if Claude Code is available
installed_mcps="false"
if command -v claude &> /dev/null; then
    if confirm "Auto-configure MCPs for Claude Code?"; then
        echo ""
        print_step "Configuring MCPs..."
        
        # Source the MCP config and run the commands
        local mcp_count=0
        local total_mcps=$(grep -c "^claude mcp add" ~/Terminal_Power/configs/claude_mcp_config)
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^claude\ mcp\ add ]]; then
                ((mcp_count++))
                local mcp_name=$(echo "$line" | awk '{print $4}')
                echo "  [$mcp_count/$total_mcps] Installing $mcp_name..."
                eval "$line" 2>/dev/null || echo "    ⚠️ Skipped (package not available)"
            fi
        done < ~/Terminal_Power/configs/claude_mcp_config
        
        installed_mcps="true"
        echo ""
        print_success "MCPs configured! Restart Claude Code to activate them."
    fi
else
    print_warning "Claude Code not found. Install it first, then run: mcp"
fi

echo ""
echo "🎉 Terminal Power Installation Complete!"
echo "========================================"
echo ""

# Show status of key components
print_step "📊 Installation Summary:"
echo ""
echo "✅ Core Scripts Installed:"
echo "   • Voice Commands (voice, voice10)"
echo "   • GitHub Search (ghsearch, findcode)"  
echo "   • Interactive Control Center (mcp, mcphelp)"
echo ""

# Check if Claude Code is available
if command -v claude &> /dev/null; then
    local mcp_count=$(claude mcp list 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ Claude Code Detected (MCPs configured: $mcp_count)"
else
    echo "⚠️  Claude Code Not Found"
    echo "   Install from: https://docs.anthropic.com/claude-code"
fi

echo ""
echo "🚀 READY TO USE!"
echo "==============="
echo ""
if [[ -n "$installed_mcps" ]] && [[ "$installed_mcps" == "true" ]]; then
    echo -e "${BLUE}🔄 To activate everything:${NC}"
    echo ""
    echo "1. 📱 Close and reopen Claude Code completely"
    echo "2. 💻 In a NEW terminal tab, run:"
    echo -e "   ${GREEN}mcp${NC}                    # Open control center"
    echo ""
    echo -e "${YELLOW}💡 Your current terminal has everything working except MCPs${NC}"
else
    echo -e "${BLUE}🎯 Everything is ready! Try these now:${NC}"
    echo ""
    echo -e "   ${GREEN}mcp${NC}                    # Open control center"  
    echo -e "   ${GREEN}weather tokyo${NC}          # Check weather"
    echo -e "   ${GREEN}qr 'Hello World'${NC}       # Generate QR codes"
    echo ""
fi

# Quick help
echo "📚 Need Help?"
echo "============="
echo "• Interactive Help: mcp"
echo "• GitHub: https://github.com/pibulus/terminal-power"
echo "• Issues: https://github.com/pibulus/terminal-power/issues"
echo ""

# Immediate success validation with working demos
echo ""
print_step "🧪 Testing what works right now..."
echo ""

# Test features that work immediately (no API keys needed)
echo -n "🌤️  Weather API: "
if curl -s --max-time 5 "https://api.open-meteo.com/v1/forecast?latitude=40.7&longitude=-74.0&current=temperature_2m" | grep -q "temperature_2m" 2>/dev/null; then
    echo -e "${GREEN}✅ Working!${NC}"
else
    echo -e "${YELLOW}⚠️ Check internet connection${NC}"
fi

echo -n "🎨 Color API: "
if curl -s --max-time 5 "https://www.thecolorapi.com/id?hex=FF69B4" | grep -q "name" 2>/dev/null; then
    echo -e "${GREEN}✅ Working!${NC}"
else
    echo -e "${YELLOW}⚠️ Check internet connection${NC}"  
fi

echo -n "📱 QR Generator: "
if curl -s --max-time 5 -I "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=test" | grep -q "200" 2>/dev/null; then
    echo -e "${GREEN}✅ Working!${NC}"
else
    echo -e "${YELLOW}⚠️ Check internet connection${NC}"
fi

echo -n "💬 Quote API: "
if curl -s --max-time 5 "https://dummyjson.com/quotes/random" | grep -q "quote" 2>/dev/null; then
    echo -e "${GREEN}✅ Working!${NC}"
else
    echo -e "${YELLOW}⚠️ Check internet connection${NC}"
fi

echo ""
echo "🚀 TERMINAL POWER ACTIVATED!"
echo ""
print_success "Installation complete! Here's what you can try RIGHT NOW:"
echo ""
echo -e "${BLUE}🎯 Try these commands immediately:${NC}"
echo "   weather tokyo          # Get weather anywhere"  
echo "   qr 'Hello World'       # Generate QR codes"
echo "   colorname FF69B4       # Identify any color"
echo "   quote                  # Get inspiring quotes"
echo ""
echo -e "${YELLOW}🎮 For the full experience:${NC}"
echo "   mcp                    # Open control center"
echo ""

# Create a quick test script
cat > ~/test-terminal-power.sh << 'EOF'
#!/bin/bash
echo "🧪 Testing Terminal Power Setup..."
echo ""

echo "📋 Checking API keys..."
[[ -n "$OPENAI_API_KEY" ]] && echo "✅ OpenAI API key set" || echo "❌ OpenAI API key missing"
[[ -n "$GOOGLE_API_KEY" ]] && echo "✅ Google API key set" || echo "❌ Google API key missing"  
[[ -n "$GITHUB_TOKEN" ]] && echo "✅ GitHub token set" || echo "❌ GitHub token missing"
[[ -n "$SUPABASE_ACCESS_TOKEN" ]] && echo "✅ Supabase token set" || echo "❌ Supabase token missing"

echo ""
echo "🛠️ Checking commands..."
[[ -f ~/voice-to-claude.sh ]] && echo "✅ Voice commands ready" || echo "❌ Voice script missing"
[[ -f ~/github-search.sh ]] && echo "✅ GitHub search ready" || echo "❌ GitHub search missing"

echo ""
echo "📱 Checking MCPs..."
claude mcp list | wc -l | awk '{print "✅ " $1 " MCPs configured"}'

echo ""
echo "🎯 Ready to test:"
echo "  voice     # Test voice transcription"
echo "  ghsearch \"search term\" repositories  # Test GitHub search"
EOF

chmod +x ~/test-terminal-power.sh

print_success "Created test script: ~/test-terminal-power.sh"
echo ""
print_warning "Run ~/test-terminal-power.sh after setting up API keys to verify everything works!"