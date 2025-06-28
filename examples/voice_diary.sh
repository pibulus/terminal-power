#!/bin/bash

# Voice Diary - Personal AI Journal with Voice Input
# Record your thoughts and let AI help organize and analyze them

DIARY_DIR="$HOME/VoiceDiary"
TODAY=$(date +%Y-%m-%d)
DIARY_FILE="$DIARY_DIR/$TODAY.md"

# Create diary directory if it doesn't exist
mkdir -p "$DIARY_DIR"

echo "🎙️ Voice Diary - AI-Powered Personal Journal"
echo "============================================"
echo ""

# Check if OpenAI API key is available
if [[ -z "$OPENAI_API_KEY" ]]; then
    echo "❌ OpenAI API key not found. Please set OPENAI_API_KEY environment variable."
    exit 1
fi

# Function to record voice entry
record_entry() {
    echo "🎤 Recording your diary entry (press Enter when ready, Ctrl+C to cancel)..."
    read -p ""
    
    echo "🎙️ Recording for 30 seconds... Speak now!"
    
    # Create temporary audio file
    AUDIO_FILE="/tmp/diary_$(date +%s).wav"
    
    # Record audio using ffmpeg
    ffmpeg -f avfoundation -i ":0" -t 30 -y "$AUDIO_FILE" -loglevel quiet
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Recording complete! Transcribing..."
        
        # Transcribe using Whisper API
        TRANSCRIPTION=$(curl -s -X POST "https://api.openai.com/v1/audio/transcriptions" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -F file=@"$AUDIO_FILE" \
            -F model=whisper-1 \
            | jq -r '.text')
        
        # Clean up audio file
        rm "$AUDIO_FILE"
        
        if [[ "$TRANSCRIPTION" != "null" ]] && [[ -n "$TRANSCRIPTION" ]]; then
            echo "📝 Transcription: $TRANSCRIPTION"
            echo ""
            
            # Add entry to diary file
            echo "## $(date '+%H:%M:%S') - Voice Entry" >> "$DIARY_FILE"
            echo "" >> "$DIARY_FILE"
            echo "$TRANSCRIPTION" >> "$DIARY_FILE"
            echo "" >> "$DIARY_FILE"
            echo "---" >> "$DIARY_FILE"
            echo "" >> "$DIARY_FILE"
            
            echo "✅ Entry saved to $DIARY_FILE"
            
            # Ask if user wants AI analysis
            read -p "🤖 Would you like AI to analyze this entry? (y/n): " analyze
            if [[ "$analyze" =~ ^[Yy]$ ]]; then
                analyze_entry "$TRANSCRIPTION"
            fi
        else
            echo "❌ Transcription failed. Please try again."
        fi
    else
        echo "❌ Recording failed. Please check your microphone setup."
    fi
}

# Function to analyze entry with AI
analyze_entry() {
    local entry_text="$1"
    echo ""
    echo "🤖 AI is analyzing your entry..."
    
    # Use OpenAI to analyze the diary entry
    ANALYSIS=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"gpt-3.5-turbo\",
            \"messages\": [
                {
                    \"role\": \"system\",
                    \"content\": \"You are a thoughtful AI journal companion. Analyze diary entries with empathy and provide helpful insights about mood, themes, and patterns. Be supportive and encouraging.\"
                },
                {
                    \"role\": \"user\",
                    \"content\": \"Please analyze this diary entry and provide insights about mood, themes, and any patterns you notice. Be supportive and constructive: $entry_text\"
                }
            ],
            \"max_tokens\": 200,
            \"temperature\": 0.7
        }" | jq -r '.choices[0].message.content')
    
    if [[ "$ANALYSIS" != "null" ]] && [[ -n "$ANALYSIS" ]]; then
        echo "🧠 AI Analysis:"
        echo "$ANALYSIS"
        echo ""
        
        # Add analysis to diary file
        echo "### 🤖 AI Insights" >> "$DIARY_FILE"
        echo "" >> "$DIARY_FILE"
        echo "$ANALYSIS" >> "$DIARY_FILE"
        echo "" >> "$DIARY_FILE"
        echo "---" >> "$DIARY_FILE"
        echo "" >> "$DIARY_FILE"
        
        echo "✅ Analysis saved to diary file"
    else
        echo "❌ AI analysis failed. Entry saved without analysis."
    fi
}

# Function to view recent entries
view_entries() {
    echo "📖 Recent Diary Entries:"
    echo "========================"
    
    # List recent diary files
    find "$DIARY_DIR" -name "*.md" -type f | sort -r | head -5 | while read file; do
        filename=$(basename "$file" .md)
        echo "📅 $filename"
    done
    
    echo ""
    read -p "Enter date (YYYY-MM-DD) to view, or press Enter for today: " date_input
    
    if [[ -z "$date_input" ]]; then
        date_input="$TODAY"
    fi
    
    view_file="$DIARY_DIR/$date_input.md"
    
    if [[ -f "$view_file" ]]; then
        echo ""
        echo "📖 Diary Entry for $date_input:"
        echo "================================="
        cat "$view_file"
    else
        echo "❌ No diary entry found for $date_input"
    fi
}

# Function to generate weekly summary
weekly_summary() {
    echo "📊 Generating Weekly Summary..."
    
    # Find entries from the last 7 days
    WEEK_AGO=$(date -j -v-7d +%Y-%m-%d)
    
    echo "🔍 Collecting entries from $WEEK_AGO to $TODAY..."
    
    # Combine recent entries
    COMBINED_ENTRIES=""
    find "$DIARY_DIR" -name "*.md" -type f -newer "$DIARY_DIR/$WEEK_AGO.md" 2>/dev/null | while read file; do
        if [[ -f "$file" ]]; then
            COMBINED_ENTRIES+=$(cat "$file")
            COMBINED_ENTRIES+="\n\n"
        fi
    done
    
    if [[ -n "$COMBINED_ENTRIES" ]]; then
        echo "🤖 AI is generating your weekly summary..."
        
        # Generate summary with AI
        SUMMARY=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -H "Content-Type: application/json" \
            -d "{
                \"model\": \"gpt-3.5-turbo\",
                \"messages\": [
                    {
                        \"role\": \"system\",
                        \"content\": \"You are a thoughtful AI journal companion. Create weekly summaries of diary entries focusing on growth, patterns, achievements, and areas for reflection.\"
                    },
                    {
                        \"role\": \"user\",
                        \"content\": \"Please create a weekly summary of these diary entries, highlighting key themes, mood patterns, achievements, and insights: $COMBINED_ENTRIES\"
                    }
                ],
                \"max_tokens\": 400,
                \"temperature\": 0.7
            }" | jq -r '.choices[0].message.content')
        
        if [[ "$SUMMARY" != "null" ]] && [[ -n "$SUMMARY" ]]; then
            echo ""
            echo "📊 Weekly Summary:"
            echo "=================="
            echo "$SUMMARY"
            
            # Save summary to file
            SUMMARY_FILE="$DIARY_DIR/weekly_summary_$TODAY.md"
            echo "# Weekly Summary - $TODAY" > "$SUMMARY_FILE"
            echo "" >> "$SUMMARY_FILE"
            echo "$SUMMARY" >> "$SUMMARY_FILE"
            
            echo ""
            echo "✅ Summary saved to $SUMMARY_FILE"
        else
            echo "❌ Failed to generate summary"
        fi
    else
        echo "❌ No recent entries found for summary"
    fi
}

# Main menu
while true; do
    echo ""
    echo "📱 Voice Diary Options:"
    echo "1. 🎙️  Record new voice entry"
    echo "2. 📖  View diary entries"
    echo "3. 📊  Generate weekly summary"
    echo "4. 📁  Open diary folder"
    echo "5. ❌  Exit"
    echo ""
    
    read -p "Choose an option (1-5): " choice
    
    case $choice in
        1)
            record_entry
            ;;
        2)
            view_entries
            ;;
        3)
            weekly_summary
            ;;
        4)
            open "$DIARY_DIR"
            echo "📁 Diary folder opened"
            ;;
        5)
            echo "👋 Thanks for journaling! Keep reflecting and growing."
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please choose 1-5."
            ;;
    esac
done