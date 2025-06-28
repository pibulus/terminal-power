#!/bin/bash
# Terminal Power Pack Manager
# Modular API extensions for the cyberpunk terminal

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

PACKS_DIR="$HOME/.terminal-power/packs"
CONFIG_DIR="$HOME/.terminal-power"

# Ensure directories exist
mkdir -p "$PACKS_DIR" "$CONFIG_DIR"

show_available_packs() {
    echo -e "${BLUE}🎨 Available Terminal Power Packs${NC}"
    echo ""
    echo -e "${GREEN}creative-pack${NC} - Design & visual APIs"
    echo "  📸 Unsplash photos, 🎨 color tools, 🌈 gradients"
    echo "  🌤️  weather, 📱 QR codes, 🎭 fake data"
    echo ""
    echo -e "${YELLOW}dev-pack${NC} - Developer utilities (coming soon)"
    echo "  💻 Code execution, 📊 charts, 🔧 API testing"
    echo ""
    echo -e "${PURPLE}fun-pack${NC} - Entertainment APIs (coming soon)"  
    echo "  🐱 Cat pics, 🎲 activities, 💬 quotes"
    echo ""
}

install_creative_pack() {
    echo -e "${BLUE}🎨 Installing Creative Pack...${NC}"
    echo ""
    
    # Create pack directory
    mkdir -p "$PACKS_DIR/creative"
    
    # Track what needs API keys
    local needs_keys=()
    local free_apis=()
    
    # Check which APIs need setup
    echo -e "${GREEN}✅ Free APIs (no setup needed):${NC}"
    echo "  🌤️  Weather (Open-Meteo)"
    echo "  🎨 Color Tools (TheColorAPI)"
    echo "  📱 QR Codes"
    echo "  🎭 Faker Data"
    echo "  💬 Quotes"
    echo "  🔗 URL Shortener"
    echo "  🖼️  Placeholder Images"
    echo ""
    
    echo -e "${YELLOW}🔑 APIs that need free keys:${NC}"
    [[ -z "$UNSPLASH_ACCESS_KEY" ]] && {
        echo "  📸 Unsplash Photos (50 requests/hour free)"
        needs_keys+=("unsplash")
    }
    [[ -z "$GOOGLE_API_KEY" ]] && {
        echo "  🔤 Google Fonts"
        needs_keys+=("google")
    }
    [[ -z "$MICROLINK_API_KEY" ]] && {
        echo "  🎨 Microlink (1,000/month free)"
        needs_keys+=("microlink")
    }
    
    echo ""
    
    if [[ ${#needs_keys[@]} -gt 0 ]]; then
        echo -e "${BLUE}🚀 Let's set up your API keys!${NC}"
        echo ""
        
        for api in "${needs_keys[@]}"; do
            setup_api_key "$api"
        done
    fi
    
    # Install pack scripts
    install_pack_scripts
    
    # Test all APIs
    test_creative_pack
    
    # Mark as installed
    echo "creative" > "$CONFIG_DIR/installed_packs.txt"
    
    echo ""
    echo -e "${GREEN}🎉 Creative Pack installed!${NC}"
    echo ""
    echo -e "${BLUE}Try these commands:${NC}"
    echo "  photo mountains"
    echo "  weather tokyo"  
    echo "  qr 'Hello World'"
    echo "  gradient pink blue"
    echo "  fake people 3"
}

setup_api_key() {
    local api="$1"
    
    case "$api" in
        "unsplash")
            echo -e "${YELLOW}📸 Setting up Unsplash...${NC}"
            echo "1. Opening Unsplash Developer page..."
            command -v open >/dev/null && open "https://unsplash.com/developers" || echo "Visit: https://unsplash.com/developers"
            echo "2. Create a new app (any name is fine)"
            echo "3. Copy your 'Access Key'"
            echo ""
            read -p "Paste your Unsplash Access Key: " key
            if [[ -n "$key" ]]; then
                echo "export UNSPLASH_ACCESS_KEY=\"$key\"" >> ~/.zshrc
                export UNSPLASH_ACCESS_KEY="$key"
                echo -e "${GREEN}✅ Unsplash configured!${NC}"
            fi
            ;;
        "google")
            echo -e "${YELLOW}🔤 Setting up Google Fonts...${NC}"
            echo "1. Opening Google Cloud Console..."
            command -v open >/dev/null && open "https://console.cloud.google.com/apis/credentials" || echo "Visit: https://console.cloud.google.com/apis/credentials"
            echo "2. Create credentials → API Key"
            echo "3. Restrict to Google Fonts API"
            echo ""
            read -p "Paste your Google API Key: " key
            if [[ -n "$key" ]]; then
                echo "export GOOGLE_FONTS_API_KEY=\"$key\"" >> ~/.zshrc
                export GOOGLE_FONTS_API_KEY="$key"
                echo -e "${GREEN}✅ Google Fonts configured!${NC}"
            fi
            ;;
        "microlink")
            echo -e "${YELLOW}🎨 Setting up Microlink...${NC}"
            echo "1. Opening Microlink signup..."
            command -v open >/dev/null && open "https://microlink.io/signup" || echo "Visit: https://microlink.io/signup"
            echo "2. Free plan gives 1,000 requests/month"
            echo "3. Copy your API key from dashboard"
            echo ""
            read -p "Paste your Microlink API Key: " key
            if [[ -n "$key" ]]; then
                echo "export MICROLINK_API_KEY=\"$key\"" >> ~/.zshrc
                export MICROLINK_API_KEY="$key"
                echo -e "${GREEN}✅ Microlink configured!${NC}"
            fi
            ;;
    esac
    echo ""
}

install_pack_scripts() {
    echo -e "${BLUE}📦 Installing pack scripts...${NC}"
    
    # Create the creative pack scripts directory
    mkdir -p "$PACKS_DIR/creative/scripts"
    
    # Copy scripts to home directory for easy access
    local script_dir="$(dirname "$0")"
    
    if [[ -f "$script_dir/weather-tools.sh" ]]; then
        cp "$script_dir/weather-tools.sh" ~/weather-tools.sh
        chmod +x ~/weather-tools.sh
        echo "  ✅ weather-tools.sh"
    fi
    
    if [[ -f "$script_dir/color-tools.sh" ]]; then
        cp "$script_dir/color-tools.sh" ~/color-tools.sh
        chmod +x ~/color-tools.sh
        echo "  ✅ color-tools.sh"
    fi
    
    # Add aliases to .zshrc if not already present
    if ! grep -q "# Terminal Power Creative Pack" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# Terminal Power Creative Pack" >> ~/.zshrc
        echo "alias weather='~/weather-tools.sh'" >> ~/.zshrc
        echo "alias colorscheme='~/color-tools.sh scheme'" >> ~/.zshrc
        echo "alias colorname='~/color-tools.sh name'" >> ~/.zshrc
        echo "alias palette='~/color-tools.sh palette'" >> ~/.zshrc
        echo "alias qr='function _qr() { curl -s \"https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=\$1\" -o qr.png && echo \"QR code saved as qr.png\"; }; _qr'" >> ~/.zshrc
        echo "alias fake='function _fake() { curl -s \"https://fakerapi.it/api/v1/\${1:-persons}?_quantity=\${2:-3}\" | jq .; }; _fake'" >> ~/.zshrc
        echo "alias quote='curl -s \"https://api.quotable.io/random\" | jq -r \".content + \\\" - \\\" + .author\"'" >> ~/.zshrc
        echo "alias shorten='function _shorten() { curl -s \"https://is.gd/create.php?format=simple&url=\$1\"; }; _shorten'" >> ~/.zshrc
        echo "  ✅ Added aliases to ~/.zshrc"
    else
        echo "  ℹ️  Aliases already in ~/.zshrc"
    fi
    
    echo -e "${GREEN}✅ Creative pack scripts installed${NC}"
    echo ""
    echo -e "${YELLOW}💡 Restart your terminal or run: source ~/.zshrc${NC}"
}

test_creative_pack() {
    echo -e "${BLUE}🧪 Testing Creative Pack APIs...${NC}"
    echo ""
    
    # Test free APIs
    echo -n "Weather API: "
    if curl -s "https://api.open-meteo.com/v1/forecast?latitude=40.7&longitude=-74.0&current=temperature_2m" | grep -q "temperature_2m"; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    echo -n "Color API: "
    if curl -s "https://www.thecolorapi.com/id?hex=FF69B4" | grep -q "name"; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    echo -n "QR API: "
    if curl -s -I "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=test" | grep -q "200"; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    # Test APIs with keys
    if [[ -n "$UNSPLASH_ACCESS_KEY" ]]; then
        echo -n "Unsplash API: "
        if curl -s "https://api.unsplash.com/photos/random" -H "Authorization: Client-ID $UNSPLASH_ACCESS_KEY" | grep -q "urls"; then
            echo -e "${GREEN}✅${NC}"
        else
            echo -e "${RED}❌${NC}"
        fi
    fi
}

show_pack_status() {
    echo -e "${BLUE}📊 Terminal Power Pack Status${NC}"
    echo ""
    
    if [[ -f "$CONFIG_DIR/installed_packs.txt" ]]; then
        while read -r pack; do
            echo -e "${GREEN}✅ $pack installed${NC}"
        done < "$CONFIG_DIR/installed_packs.txt"
    else
        echo -e "${YELLOW}No packs installed yet${NC}"
        echo ""
        echo "Install your first pack:"
        echo "  mcp install creative"
    fi
}

# Main command handler
case "${1:-}" in
    "list"|"packs")
        show_available_packs
        ;;
    "install")
        case "$2" in
            "creative"|"creative-pack")
                install_creative_pack
                ;;
            *)
                echo "Available packs: creative"
                ;;
        esac
        ;;
    "status")
        show_pack_status
        ;;
    "test")
        if [[ "$2" == "creative" ]]; then
            test_creative_pack
        else
            echo "Available tests: creative"
        fi
        ;;
    *)
        echo -e "${BLUE}🎨 Terminal Power Pack Manager${NC}"
        echo ""
        echo "Commands:"
        echo "  mcp packs           - List available packs"
        echo "  mcp install <pack>  - Install a pack with setup"
        echo "  mcp status          - Show installed packs"
        echo "  mcp test <pack>     - Test pack APIs"
        echo ""
        echo "Available packs: creative"
        ;;
esac