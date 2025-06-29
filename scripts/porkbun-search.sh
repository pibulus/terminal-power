#!/bin/bash
# Porkbun Domain Search - Terminal Power Extension
# Quick domain availability checker using Porkbun API

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# API credentials from environment
PORKBUN_API_KEY="${PORKBUN_API_KEY:-}"
PORKBUN_SECRET_KEY="${PORKBUN_SECRET_KEY:-}"

# Setup guide for users
show_setup_guide() {
    echo -e "${BLUE}🏷️ Porkbun Domain Search Setup${NC}"
    echo ""
    echo -e "${YELLOW}💡 You need free Porkbun API keys to search domains${NC}"
    echo ""
    echo "1. Sign up at: https://porkbun.com"
    echo "2. Go to API Access in your account dashboard"
    command -v open >/dev/null && { 
        echo "   Opening Porkbun dashboard..." && open "https://porkbun.com/account/api"
    } || echo "   Visit: https://porkbun.com/account/api"
    echo "3. Create API Key (free - give it any name)"
    echo "4. Add to your ~/.zshrc:"
    echo ""
    echo -e "${GREEN}export PORKBUN_API_KEY=\"your_api_key_here\"${NC}"
    echo -e "${GREEN}export PORKBUN_SECRET_KEY=\"your_secret_key_here\"${NC}"
    echo ""
    echo "5. Restart terminal or run: source ~/.zshrc"
    echo ""
    echo -e "${BLUE}Then run: $0 example.com${NC}"
}

# Check if API keys are configured
check_api_setup() {
    if [[ -z "$PORKBUN_API_KEY" || -z "$PORKBUN_SECRET_KEY" ]]; then
        show_setup_guide
        return 1
    fi
    return 0
}

# Function to check domain
check_domain() {
    local domain="$1"
    
    # Check API setup first
    check_api_setup || return 1
    
    if [[ -z "$domain" ]]; then
        echo -e "${RED}❌ Please provide a domain to check${NC}"
        echo "Usage: $0 example.com"
        return 1
    fi
    
    echo -e "${BLUE}🔍 Checking availability for: ${YELLOW}$domain${NC}"
    echo ""
    
    # API request
    local response=$(curl -s -X POST "https://api.porkbun.com/api/json/v3/domain/checkDomain/$domain" \
        -H "Content-Type: application/json" \
        -d "{
            \"secretapikey\": \"$PORKBUN_SECRET_KEY\",
            \"apikey\": \"$PORKBUN_API_KEY\"
        }")
    
    # Check if request was successful
    if [[ -z "$response" ]]; then
        echo -e "${RED}❌ Failed to connect to Porkbun API${NC}"
        return 1
    fi
    
    # Parse response
    local status=$(echo "$response" | jq -r '.status // "ERROR"')
    local available=$(echo "$response" | jq -r '.response.avail // "no"')
    local price=$(echo "$response" | jq -r '.response.price // ""')
    local regular_price=$(echo "$response" | jq -r '.response.regularPrice // ""')
    local renewal_price=$(echo "$response" | jq -r '.response.additional.renewal.price // ""')
    local promo=$(echo "$response" | jq -r '.response.firstYearPromo // "no"')
    local message=$(echo "$response" | jq -r '.message // ""')
    
    if [[ "$status" == "SUCCESS" ]]; then
        if [[ "$available" == "yes" ]]; then
            echo -e "${GREEN}✅ $domain is AVAILABLE!${NC}"
            echo ""
            [[ -n "$price" && "$price" != "null" ]] && \
                echo -e "💰 Registration: ${GREEN}\$$price${NC}"
            [[ -n "$regular_price" && "$regular_price" != "null" && "$regular_price" != "$price" ]] && \
                echo -e "💰 Regular price: \$$regular_price"
            [[ -n "$renewal_price" && "$renewal_price" != "null" ]] && \
                echo -e "🔄 Renewal: \$$renewal_price/year"
            [[ "$promo" == "yes" ]] && \
                echo -e "🎉 First year promo price!"
        else
            echo -e "${RED}❌ $domain is NOT available${NC}"
        fi
    else
        echo -e "${RED}❌ Error: $message${NC}"
        
        # Show raw response for debugging if it's a rate limit
        if [[ "$message" == *"checks within"* ]]; then
            echo -e "${YELLOW}⏱️  Rate limited - wait 10 seconds between checks${NC}"
        else
            echo ""
            echo -e "${YELLOW}Debug response:${NC}"
            echo "$response" | jq . 2>/dev/null || echo "$response"
        fi
    fi
}

# Bulk domain checker
check_multiple_domains() {
    local base_name="$1"
    local extensions=("com" "org" "net" "io" "dev" "app" "ai" "tech")
    
    # Check API setup first
    check_api_setup || return 1
    
    echo -e "${BLUE}🔍 Bulk checking: ${YELLOW}$base_name${NC}"
    echo ""
    
    for ext in "${extensions[@]}"; do
        check_domain "$base_name.$ext"
        echo ""
        sleep 12  # Porkbun rate limit: 1 check per 10 seconds
    done
}

# Generate domain suggestions
suggest_domains() {
    local keyword="$1"
    
    # Check API setup first
    check_api_setup || return 1
    
    local suggestions=(
        "$keyword.com"
        "$keyword.io"
        "$keyword.dev"
        "$keyword.app"
        "get$keyword.com"
        "try$keyword.com"
        "$keyword-app.com"
        "$keyword-ai.com"
        "$keyword.tech"
        "$keyword.org"
    )
    
    echo -e "${BLUE}💡 Domain suggestions for: ${YELLOW}$keyword${NC}"
    echo ""
    
    for domain in "${suggestions[@]}"; do
        check_domain "$domain"
        echo ""
        sleep 12  # Porkbun rate limit: 1 check per 10 seconds
    done
}

# Show pricing for popular TLDs
show_pricing() {
    # Check API setup first
    check_api_setup || return 1
    
    echo -e "${BLUE}💰 Porkbun Domain Pricing${NC}"
    echo ""
    
    local response=$(curl -s -X POST "https://api.porkbun.com/api/json/v3/pricing/get" \
        -H "Content-Type: application/json" \
        -d "{
            \"secretapikey\": \"$PORKBUN_SECRET_KEY\",
            \"apikey\": \"$PORKBUN_API_KEY\"
        }")
    
    local popular_tlds=("com" "org" "net" "io" "dev" "app" "ai" "tech" "co")
    
    for tld in "${popular_tlds[@]}"; do
        local registration=$(echo "$response" | jq -r ".pricing.\"$tld\".registration // \"N/A\"")
        local renewal=$(echo "$response" | jq -r ".pricing.\"$tld\".renewal // \"N/A\"")
        
        if [[ "$registration" != "N/A" ]]; then
            echo -e "${GREEN}.$tld${NC} - Registration: ${YELLOW}\$$registration${NC} | Renewal: \$$renewal"
        fi
    done
}

# Main execution
main() {
    case "${1:-}" in
        "pricing"|"price")
            show_pricing
            ;;
        "bulk")
            if [[ -z "$2" ]]; then
                echo "Usage: $0 bulk <name>"
                echo "Example: $0 bulk myproject"
                exit 1
            fi
            echo -e "${YELLOW}⚠️  Note: Rate limited to 1 check per 10 seconds${NC}"
            echo ""
            check_multiple_domains "$2"
            ;;
        "suggest")
            if [[ -z "$2" ]]; then
                echo "Usage: $0 suggest <keyword>"
                echo "Example: $0 suggest terminal"
                exit 1
            fi
            echo -e "${YELLOW}⚠️  Note: Rate limited to 1 check per 10 seconds${NC}"
            echo ""
            suggest_domains "$2"
            ;;
        "")
            echo -e "${BLUE}🏷️  Porkbun Domain Search${NC}"
            echo ""
            echo "Usage:"
            echo "  $0 <domain>           - Check single domain"
            echo "  $0 pricing            - Show domain pricing"
            echo "  $0 bulk <name>        - Check multiple extensions (slow)"
            echo "  $0 suggest <keyword>  - Get domain suggestions (slow)"
            echo ""
            echo "Examples:"
            echo "  $0 example.com"
            echo "  $0 pricing"
            echo "  $0 bulk myproject"
            echo ""
            echo -e "${YELLOW}💡 Tip: Use 'pricing' to see costs before checking domains${NC}"
            ;;
        *)
            check_domain "$1"
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