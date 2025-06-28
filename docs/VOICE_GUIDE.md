# 🎙️ VOICE COMMANDS GUIDE

**Control your terminal with your voice using Whisper API**

---

## 🚀 **QUICK START**

```bash
# Record and transcribe voice (5 seconds)
voice

# Record longer commands (10 seconds)
voice10

# Custom duration
~/voice-to-claude.sh 15
```

---

## 🎯 **HOW IT WORKS**

1. **Record audio** using your Mac's microphone
2. **Send to OpenAI Whisper API** for transcription
3. **Display transcribed text** for you to copy/execute
4. **Integrate with Claude Code** for AI-powered commands

---

## 💬 **EXAMPLE VOICE COMMANDS**

### **Development Commands:**
```
"Create a new Deno project with Fresh framework"
"Set up Supabase authentication for my app"
"Find GitHub examples of middleware in Deno"
"Generate API documentation for my project"
```

### **System Commands:**
```
"Take a screenshot and save to desktop"
"Organize my downloads folder by file type"
"Open my development environment with terminal and VS Code"
"Backup my project files with timestamp"
```

### **Creative Commands:**
```
"Generate a cyberpunk wallpaper using DALL-E"
"Create a lofi track in Ableton Live"
"Design a logo for my startup"
"Generate color palette for my website"
```

### **Data & Email:**
```
"Show me unread emails about business opportunities"
"Create a calendar event for tomorrow's meeting"
"Query my database for recent user signups"
"Export my project data as JSON"
```

---

## 🔧 **SETUP & REQUIREMENTS**

### **Prerequisites:**
- OpenAI API key (for Whisper)
- ffmpeg installed (`brew install ffmpeg`)
- jq installed (`brew install jq`)
- Microphone access enabled

### **Configuration:**
The voice commands are configured in your `.zshrc`:
```bash
# Voice shortcuts
alias voice='~/voice-to-claude.sh'
alias voice5='~/voice-to-claude.sh 5'
alias voice10='~/voice-to-claude.sh 10'

# API key for Whisper
export OPENAI_API_KEY="your-key-here"
export WHISPER_API_KEY="$OPENAI_API_KEY"
```

---

## 📝 **SCRIPT BREAKDOWN**

The `voice-to-claude.sh` script:

1. **Records audio** using ffmpeg:
   ```bash
   ffmpeg -f avfoundation -i ":0" -t ${DURATION} -y ${AUDIO_FILE}
   ```

2. **Sends to Whisper API**:
   ```bash
   curl -s -X POST "https://api.openai.com/v1/audio/transcriptions" \
       -H "Authorization: Bearer ${OPENAI_API_KEY}" \
       -F file=@${AUDIO_FILE} \
       -F model=whisper-1
   ```

3. **Processes and displays** the transcription

---

## 🚑 **TROUBLESHOOTING**

### **"No audio device found"**
- Check System Preferences > Security & Privacy > Microphone
- Allow Terminal/iTerm2 microphone access

### **"ffmpeg not found"**
```bash
brew install ffmpeg
```

### **"API key not working"**
- Verify your OpenAI API key is valid
- Check you have credits in your OpenAI account
- Ensure the key is exported in your shell:
  ```bash
  echo $OPENAI_API_KEY
  ```

### **"Poor transcription quality"**
- Speak clearly and close to microphone
- Use longer recording duration (voice10)
- Reduce background noise

---

## 🎆 **ADVANCED USAGE**

### **Chain Commands:**
```bash
# Use voice to find code, then execute the search
voice  # "find authentication examples in deno"
ghsearch "deno auth examples" repositories
```

### **Custom Voice Triggers:**
Edit `voice-to-claude.sh` to add automatic command execution:
```bash
if [[ "$TRANSCRIPTION" == *"screenshot"* ]]; then
    screencapture ~/Desktop/screenshot-$(date +%Y%m%d_%H%M%S).png
    echo "✅ Screenshot taken!"
fi
```

### **Integration with Claude:**
Use transcribed text directly with Claude Code:
```bash
voice && claude chat "$TRANSCRIPTION"
```

---

## 🔮 **FUTURE FEATURES**

- **Wake word detection** ("Hey Claude")
- **Continuous listening mode**
- **Voice responses** from Claude
- **Custom command shortcuts**
- **Noise cancellation**

---

**Transform your terminal into a voice-controlled AI command center!** 🤖⚡