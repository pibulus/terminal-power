#!/bin/bash
# Color Tools - TheColorAPI + Microlink Integration
# Color manipulation and palette extraction

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Color scheme generation
generate_scheme() {
    local hex="$1"
    local mode="${2:-analogic}"
    
    # Remove # if present
    hex="${hex#"#"}"
    
    if [[ -z "$hex" ]]; then
        echo "Usage: colorscheme <hex> [mode]"
        echo "Modes: analogic, monochromatic, triad, complement"
        return 1
    fi
    
    echo -e "${BLUE}🎨 Color Scheme: ${mode} from #${hex}${NC}"
    echo ""
    
    local response=$(curl -s "https://www.thecolorapi.com/scheme?hex=${hex}&mode=${mode}&count=5")
    
    if [[ -z "$response" ]]; then
        echo -e "${RED}❌ Failed to get color scheme${NC}"
        return 1
    fi
    
    echo "$response" | jq -r '.colors[] | "🎨 \(.hex.value) - \(.name.value)"'
}

# Identify a color
identify_color() {
    local hex="$1"
    
    # Remove # if present
    hex="${hex#"#"}"
    
    if [[ -z "$hex" ]]; then
        echo "Usage: colorname <hex>"
        return 1
    fi
    
    echo -e "${BLUE}🔍 Identifying color #${hex}${NC}"
    echo ""
    
    local response=$(curl -s "https://www.thecolorapi.com/id?hex=${hex}")
    
    if [[ -z "$response" ]]; then
        echo -e "${RED}❌ Failed to identify color${NC}"
        return 1
    fi
    
    local name=$(echo "$response" | jq -r '.name.value')
    local rgb=$(echo "$response" | jq -r '.rgb.value')
    local hsl=$(echo "$response" | jq -r '.hsl.value')
    
    echo -e "${GREEN}🎨 Name: ${name}${NC}"
    echo -e "🌈 Hex: #${hex}"
    echo -e "🔴 RGB: ${rgb}"
    echo -e "🎯 HSL: ${hsl}"
}

# Extract palette from website (requires Microlink)
extract_palette() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        echo "Usage: palette <url>"
        return 1
    fi
    
    # Add protocol if missing
    if [[ ! "$url" =~ ^https?:// ]]; then
        url="https://$url"
    fi
    
    echo -e "${BLUE}🎨 Extracting palette from ${url}${NC}"
    echo ""
    
    # Use correct Microlink API format
    if [[ -n "$MICROLINK_API_KEY" ]]; then
        local response=$(curl -s "https://api.microlink.io/?url=${url}&palette" \
            -H "X-API-Key: $MICROLINK_API_KEY")
    else
        # Use free tier - correct format without =true
        local response=$(curl -s "https://api.microlink.io/?url=${url}&palette")
    fi
    
    if [[ -z "$response" ]]; then
        echo -e "${RED}❌ Failed to extract palette${NC}"
        return 1
    fi
    
    local status=$(echo "$response" | jq -r '.status')
    if [[ "$status" != "success" ]]; then
        echo -e "${RED}❌ Error: $(echo "$response" | jq -r '.message // "Unknown error"')${NC}"
        echo -e "${YELLOW}Debug response:${NC}"
        echo "$response" | jq .
        return 1
    fi
    
    echo -e "${GREEN}Dominant colors from ${url}:${NC}"
    echo ""
    
    # Check if data.image exists and has palette
    local has_palette=$(echo "$response" | jq -r '.data.image.palette // empty')
    if [[ -n "$has_palette" ]]; then
        echo "$response" | jq -r '.data.image.palette[]' | while read -r color; do
            echo -e "🎨 ${color}"
        done
    else
        # Try alternative path for palette data
        echo "$response" | jq -r '.data.palette[]?' 2>/dev/null | while read -r color; do
            echo -e "🎨 ${color}"
        done || echo -e "${YELLOW}⚠️  No palette data found for this URL${NC}"
    fi
}

# Generate random color
random_color() {
    local response=$(curl -s "https://www.thecolorapi.com/random")
    
    if [[ -z "$response" ]]; then
        echo -e "${RED}❌ Failed to generate random color${NC}"
        return 1
    fi
    
    local hex=$(echo "$response" | jq -r '.hex.value')
    local name=$(echo "$response" | jq -r '.name.value')
    local rgb=$(echo "$response" | jq -r '.rgb.value')
    
    echo -e "${BLUE}🎲 Random Color${NC}"
    echo ""
    echo -e "${GREEN}🎨 ${name}${NC}"
    echo -e "🌈 ${hex}"
    echo -e "🔴 ${rgb}"
}

# Convert colors
convert_color() {
    local color="$1"
    local from_format="$2"
    local to_format="$3"
    
    # Simple conversion using TheColorAPI
    echo -e "${BLUE}🔄 Color Conversion${NC}"
    echo ""
    echo "Feature coming soon - use colorname for now"
}

# Main function
main() {
    case "${1:-}" in
        "scheme")
            generate_scheme "$2" "$3"
            ;;
        "name"|"identify")
            identify_color "$2"
            ;;
        "palette")
            extract_palette "$2"
            ;;
        "random")
            random_color
            ;;
        "convert")
            convert_color "$2" "$3" "$4"
            ;;
        "")
            echo -e "${BLUE}🎨 Color Tools${NC}"
            echo ""
            echo "Commands:"
            echo "  colorscheme <hex> [mode]    - Generate color scheme"
            echo "  colorname <hex>             - Identify color name"
            echo "  palette <url>               - Extract website colors"
            echo "  randomcolor                 - Generate random color"
            echo ""
            echo "Examples:"
            echo "  colorscheme FF69B4 analogic"
            echo "  colorname '#FF1493'"
            echo "  palette stripe.com"
            echo "  randomcolor"
            echo ""
            echo "Scheme modes: analogic, monochromatic, triad, complement"
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            echo "Run 'color-tools' for help"
            ;;
    esac
}

# Check dependencies
if ! command -v jq >/dev/null 2>&1; then
    echo -e "${RED}❌ jq is required for JSON parsing${NC}"
    echo "Install with: brew install jq"
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}❌ curl is required for API requests${NC}"
    exit 1
fi

# Run main function
main "$@"