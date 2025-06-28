#!/bin/bash

# 🎙️ Voice-to-Claude Terminal Script
# Records audio, transcribes with Whisper API, and executes as command

set -e

# Configuration
AUDIO_FILE="/tmp/voice_command.wav"
DURATION=${1:-5}  # Default 5 seconds, or pass duration as argument

echo "🎙️  Recording for ${DURATION} seconds... (speak now)"

# Record audio using ffmpeg (works on macOS)
ffmpeg -f avfoundation -i ":0" -t ${DURATION} -y ${AUDIO_FILE} -loglevel quiet

if [[ ! -f ${AUDIO_FILE} ]]; then
    echo "❌ Recording failed"
    exit 1
fi

echo "🧠 Transcribing with Whisper API..."

# Send to Whisper API
TRANSCRIPTION=$(curl -s -X POST "https://api.openai.com/v1/audio/transcriptions" \
    -H "Authorization: Bearer ${OPENAI_API_KEY}" \
    -F file=@${AUDIO_FILE} \
    -F model=whisper-1 \
    | jq -r '.text')

if [[ -z "$TRANSCRIPTION" || "$TRANSCRIPTION" == "null" ]]; then
    echo "❌ Transcription failed"
    exit 1
fi

echo "📝 Transcribed: \"${TRANSCRIPTION}\""

# Voice confirmation if available
if [[ -f ~/Terminal_Power/scripts/voice-response.sh ]]; then
    ~/Terminal_Power/scripts/voice-response.sh "I heard: ${TRANSCRIPTION}"
fi

# Clean up audio file
rm -f ${AUDIO_FILE}

# Check if it's a Claude command (starts with common AI phrases)
if [[ "$TRANSCRIPTION" =~ ^(hey claude|claude|create|generate|build|make|show me|find|search) ]]; then
    echo "🤖 Sending to Claude..."
    echo "💬 Command: ${TRANSCRIPTION}"
    # This will be processed by Claude Code when you run the script
    echo "${TRANSCRIPTION}"
else
    echo "💭 Treating as regular terminal command..."
    read -p "Execute '${TRANSCRIPTION}'? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        eval "${TRANSCRIPTION}"
    else
        echo "❌ Command cancelled"
    fi
fi