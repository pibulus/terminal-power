#!/bin/bash
# Voice Response System - Make Terminal Power Talk Back
# Supports macOS say, Linux espeak, and ElevenLabs API

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
VOICE_ENABLED="${TERMINAL_POWER_VOICE_ENABLED:-true}"
VOICE_ENGINE="${TERMINAL_POWER_VOICE_ENGINE:-auto}"  # auto, say, espeak, elevenlabs
VOICE_RATE="${TERMINAL_POWER_VOICE_RATE:-200}"      # Words per minute
VOICE_NAME="${TERMINAL_POWER_VOICE_NAME:-Samantha}" # macOS voice name

# Detect available TTS engines
detect_tts_engines() {
    local engines=()
    
    # Check macOS say
    if command -v say >/dev/null 2>&1; then
        engines+=("say")
    fi
    
    # Check Linux espeak
    if command -v espeak >/dev/null 2>&1; then
        engines+=("espeak")
    fi
    
    # Check ElevenLabs API
    if [[ -n "$ELEVENLABS_API_KEY" ]]; then
        engines+=("elevenlabs")
    fi
    
    echo "${engines[@]}"
}

# Choose best TTS engine
choose_tts_engine() {
    local available=($(detect_tts_engines))
    
    case "$VOICE_ENGINE" in
        "auto")
            # Prefer ElevenLabs > say > espeak
            if [[ " ${available[*]} " =~ " elevenlabs " ]]; then
                echo "elevenlabs"
            elif [[ " ${available[*]} " =~ " say " ]]; then
                echo "say"
            elif [[ " ${available[*]} " =~ " espeak " ]]; then
                echo "espeak"
            else
                echo "none"
            fi
            ;;
        *)
            if [[ " ${available[*]} " =~ " $VOICE_ENGINE " ]]; then
                echo "$VOICE_ENGINE"
            else
                echo "none"
            fi
            ;;
    esac
}

# Speak using macOS say
speak_with_say() {
    local text="$1"
    local voice="${2:-$VOICE_NAME}"
    local rate="${3:-$VOICE_RATE}"
    
    echo -e "${BLUE}🗣️ Terminal Power says:${NC} $text"
    say -v "$voice" -r "$rate" "$text" &
}

# Speak using Linux espeak  
speak_with_espeak() {
    local text="$1"
    local rate="${2:-$VOICE_RATE}"
    
    echo -e "${BLUE}🗣️ Terminal Power says:${NC} $text"
    espeak -s "$rate" "$text" &
}

# Speak using ElevenLabs API
speak_with_elevenlabs() {
    local text="$1"
    local voice_id="${ELEVENLABS_VOICE_ID:-21m00Tcm4TlvDq8ikWAM}"  # Default: Rachel
    
    echo -e "${BLUE}🗣️ Terminal Power says:${NC} $text"
    echo -e "${YELLOW}⚡ Using ElevenLabs premium voice...${NC}"
    
    # Generate audio with ElevenLabs
    local response=$(curl -s -X POST \
        "https://api.elevenlabs.io/v1/text-to-speech/${voice_id}" \
        -H "Accept: audio/mpeg" \
        -H "Content-Type: application/json" \
        -H "xi-api-key: $ELEVENLABS_API_KEY" \
        -d "{
            \"text\": \"$text\",
            \"model_id\": \"eleven_monolingual_v1\",
            \"voice_settings\": {
                \"stability\": 0.5,
                \"similarity_boost\": 0.5
            }
        }" \
        --output /tmp/terminal_power_speech.mp3)
    
    # Play the audio
    if [[ -f /tmp/terminal_power_speech.mp3 ]]; then
        if command -v afplay >/dev/null 2>&1; then
            afplay /tmp/terminal_power_speech.mp3 &
        elif command -v mpg123 >/dev/null 2>&1; then
            mpg123 /tmp/terminal_power_speech.mp3 &
        elif command -v vlc >/dev/null 2>&1; then
            vlc --intf dummy /tmp/terminal_power_speech.mp3 &
        else
            echo -e "${RED}❌ No audio player found for ElevenLabs audio${NC}"
        fi
        
        # Cleanup after playing
        sleep 5 && rm -f /tmp/terminal_power_speech.mp3 &
    else
        echo -e "${RED}❌ Failed to generate ElevenLabs audio${NC}"
        # Fallback to system TTS
        speak_with_say "$text"
    fi
}

# Main speak function
speak() {
    local text="$1"
    
    if [[ -z "$text" ]]; then
        echo "Usage: speak <text>"
        return 1
    fi
    
    if [[ "$VOICE_ENABLED" != "true" ]]; then
        echo -e "${YELLOW}🔇 Voice responses disabled${NC}"
        return 0
    fi
    
    local engine=$(choose_tts_engine)
    
    case "$engine" in
        "say")
            speak_with_say "$text"
            ;;
        "espeak")
            speak_with_espeak "$text"
            ;;
        "elevenlabs")
            speak_with_elevenlabs "$text"
            ;;
        "none")
            echo -e "${YELLOW}⚠️  No TTS engine available${NC}"
            echo -e "${BLUE}💬 Would say:${NC} $text"
            ;;
    esac
}

# Smart response for different types of output
smart_response() {
    local command="$1"
    local output="$2"
    
    case "$command" in
        "weather")
            if echo "$output" | grep -q "°C"; then
                local temp=$(echo "$output" | grep -o '[0-9\.]*°C' | head -1)
                local condition=$(echo "$output" | grep -E "(☀️|⛅|🌧️|❄️|⛈️)" | head -1)
                speak "The weather is ${temp} with ${condition}"
            else
                speak "Weather information retrieved"
            fi
            ;;
        "palette")
            local color_count=$(echo "$output" | grep -c "🎨")
            speak "I found ${color_count} colors from that website"
            ;;
        "colorscheme")
            speak "Generated a beautiful color scheme for you"
            ;;
        "qr")
            speak "QR code generated and saved"
            ;;
        "fake")
            if echo "$output" | grep -q "persons"; then
                speak "Generated fake person data for testing"
            elif echo "$output" | grep -q "companies"; then
                speak "Generated fake company data for testing"
            else
                speak "Test data generated"
            fi
            ;;
        "quote")
            # Extract just the quote part for speaking
            local quote_text=$(echo "$output" | cut -d'-' -f1 | tr -d '"')
            speak "$quote_text"
            ;;
        "domains")
            if echo "$output" | grep -q "AVAILABLE"; then
                speak "Great news! That domain is available"
            else
                speak "Sorry, that domain is not available"
            fi
            ;;
        *)
            speak "Command completed successfully"
            ;;
    esac
}

# Voice settings management
configure_voice() {
    case "${1:-}" in
        "enable")
            echo "export TERMINAL_POWER_VOICE_ENABLED=true" >> ~/.zshrc
            echo -e "${GREEN}✅ Voice responses enabled${NC}"
            speak "Voice responses are now enabled"
            ;;
        "disable")
            echo "export TERMINAL_POWER_VOICE_ENABLED=false" >> ~/.zshrc
            echo -e "${YELLOW}🔇 Voice responses disabled${NC}"
            ;;
        "engine")
            local engine="$2"
            if [[ -n "$engine" ]]; then
                echo "export TERMINAL_POWER_VOICE_ENGINE=$engine" >> ~/.zshrc
                echo -e "${GREEN}✅ Voice engine set to: $engine${NC}"
                speak "Voice engine changed to $engine"
            else
                echo "Available engines: $(detect_tts_engines)"
            fi
            ;;
        "voice")
            if command -v say >/dev/null 2>&1; then
                echo "Available voices:"
                say -v ? | head -10
                echo ""
                echo "Set voice: voice-config voice <name>"
            else
                echo "Voice selection only available on macOS"
            fi
            ;;
        "test")
            speak "Terminal Power voice test successful. Your cyberpunk AI is online and ready."
            ;;
        *)
            echo -e "${BLUE}🗣️ Voice Configuration${NC}"
            echo ""
            echo "Commands:"
            echo "  voice-config enable      - Enable voice responses"
            echo "  voice-config disable     - Disable voice responses"
            echo "  voice-config engine <name> - Set TTS engine (say/espeak/elevenlabs)"
            echo "  voice-config voice       - List available voices (macOS)"
            echo "  voice-config test        - Test voice output"
            echo ""
            echo "Current settings:"
            echo "  Enabled: $VOICE_ENABLED"
            echo "  Engine: $(choose_tts_engine)"
            echo "  Available: $(detect_tts_engines)"
            ;;
    esac
}

# Main function
main() {
    case "${1:-}" in
        "config")
            configure_voice "${@:2}"
            ;;
        "smart")
            smart_response "$2" "$3"
            ;;
        *)
            speak "$*"
            ;;
    esac
}

# Run main function if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi