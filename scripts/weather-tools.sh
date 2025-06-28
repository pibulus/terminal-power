#!/bin/bash
# Weather Tools - Open-Meteo API Integration
# Free weather data with no API key required

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get coordinates for a location using nominatim
get_coordinates() {
    local location="$1"
    if [[ -z "$location" ]]; then
        echo "Usage: weather <location>"
        return 1
    fi
    
    # Use free nominatim API to get coordinates
    local response=$(curl -s "https://nominatim.openstreetmap.org/search?q=${location}&format=json&limit=1")
    
    if [[ $(echo "$response" | jq length) -eq 0 ]]; then
        echo -e "${RED}❌ Location '$location' not found${NC}"
        return 1
    fi
    
    local lat=$(echo "$response" | jq -r '.[0].lat')
    local lon=$(echo "$response" | jq -r '.[0].lon')
    local display_name=$(echo "$response" | jq -r '.[0].display_name')
    
    echo "$lat,$lon,$display_name"
}

# Get current weather
get_current_weather() {
    local lat="$1"
    local lon="$2"
    local location_name="$3"
    
    local response=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&timezone=auto")
    
    if [[ -z "$response" ]]; then
        echo -e "${RED}❌ Failed to get weather data${NC}"
        return 1
    fi
    
    local temp=$(echo "$response" | jq -r '.current.temperature_2m')
    local humidity=$(echo "$response" | jq -r '.current.relative_humidity_2m')
    local wind=$(echo "$response" | jq -r '.current.wind_speed_10m')
    local weather_code=$(echo "$response" | jq -r '.current.weather_code')
    
    # Weather code to description mapping (simplified)
    local weather_desc
    case "$weather_code" in
        0) weather_desc="☀️ Clear sky" ;;
        1|2|3) weather_desc="⛅ Partly cloudy" ;;
        45|48) weather_desc="🌫️ Foggy" ;;
        51|53|55) weather_desc="🌦️ Drizzle" ;;
        61|63|65) weather_desc="🌧️ Rain" ;;
        71|73|75) weather_desc="❄️ Snow" ;;
        95|96|99) weather_desc="⛈️ Thunderstorm" ;;
        *) weather_desc="🌤️ Mixed conditions" ;;
    esac
    
    echo -e "${BLUE}🌤️ Weather for ${location_name}${NC}"
    echo ""
    echo -e "${GREEN}${weather_desc}${NC}"
    echo -e "🌡️  Temperature: ${YELLOW}${temp}°C${NC}"
    echo -e "💧 Humidity: ${humidity}%"
    echo -e "💨 Wind: ${wind} km/h"
}

# Get forecast
get_forecast() {
    local lat="$1"
    local lon="$2"
    local location_name="$3"
    local days="${4:-3}"
    
    local response=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&daily=temperature_2m_max,temperature_2m_min,weather_code&timezone=auto&forecast_days=${days}")
    
    if [[ -z "$response" ]]; then
        echo -e "${RED}❌ Failed to get forecast data${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📅 ${days}-Day Forecast for ${location_name}${NC}"
    echo ""
    
    local dates=($(echo "$response" | jq -r '.daily.time[]'))
    local max_temps=($(echo "$response" | jq -r '.daily.temperature_2m_max[]'))
    local min_temps=($(echo "$response" | jq -r '.daily.temperature_2m_min[]'))
    local codes=($(echo "$response" | jq -r '.daily.weather_code[]'))
    
    for i in $(seq 0 $((days-1))); do
        local date=${dates[$i]}
        local max_temp=${max_temps[$i]}
        local min_temp=${min_temps[$i]}
        local code=${codes[$i]}
        
        # Format date
        local formatted_date=$(date -j -f "%Y-%m-%d" "$date" "+%a %b %d" 2>/dev/null || echo "$date")
        
        # Weather emoji
        local emoji
        case "$code" in
            0) emoji="☀️" ;;
            1|2|3) emoji="⛅" ;;
            45|48) emoji="🌫️" ;;
            51|53|55) emoji="🌦️" ;;
            61|63|65) emoji="🌧️" ;;
            71|73|75) emoji="❄️" ;;
            95|96|99) emoji="⛈️" ;;
            *) emoji="🌤️" ;;
        esac
        
        echo -e "${emoji} ${formatted_date}: ${YELLOW}${max_temp}°/${min_temp}°C${NC}"
    done
}

# Main function
main() {
    case "${1:-}" in
        "coords")
            if [[ -z "$2" || -z "$3" ]]; then
                echo "Usage: weather coords <latitude> <longitude>"
                exit 1
            fi
            get_current_weather "$2" "$3" "Custom Location"
            ;;
        "forecast")
            if [[ -z "$2" ]]; then
                echo "Usage: weather forecast <location> [days]"
                exit 1
            fi
            local coords=$(get_coordinates "$2")
            if [[ $? -eq 0 ]]; then
                IFS=',' read -r lat lon display_name <<< "$coords"
                get_forecast "$lat" "$lon" "$display_name" "${3:-3}"
            fi
            ;;
        "")
            echo -e "${BLUE}🌤️ Weather Tools${NC}"
            echo ""
            echo "Usage:"
            echo "  weather <location>              - Current weather"
            echo "  weather coords <lat> <lon>      - Weather by coordinates"
            echo "  weather forecast <location>     - 3-day forecast"
            echo "  weather forecast <location> 7   - 7-day forecast"
            echo ""
            echo "Examples:"
            echo "  weather tokyo"
            echo "  weather coords 37.7749 -122.4194"
            echo "  weather forecast melbourne 5"
            ;;
        *)
            # Default: current weather for location
            local coords=$(get_coordinates "$1")
            if [[ $? -eq 0 ]]; then
                IFS=',' read -r lat lon display_name <<< "$coords"
                get_current_weather "$lat" "$lon" "$display_name"
            fi
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