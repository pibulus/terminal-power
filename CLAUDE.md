# Terminal Power - Claude AI Context

**You are working on Terminal Power - a voice-controlled AI terminal workspace that transforms how developers interact with their computers.**

## 🎯 Project Overview

Terminal Power is an open-source package that turns any terminal into a cyberpunk AI command center featuring:
- Voice commands via Whisper API transcription
- 16 Model Context Protocol (MCP) servers for AI capabilities
- Interactive control center with beautiful gum-based UI
- GitHub code discovery engine
- Cross-platform installation and setup

## 🤖 Your Role & Capabilities

When working on Terminal Power, you have access to these MCPs:

### **AI & Creative (4 MCPs)**
- `outsource` - Multi-AI access (DALL-E, GPT-4, Claude)
- `huggingface` - 300k+ free AI models
- `ableton-live` - Music production control
- `sequential-thinking` - Enhanced reasoning

### **Data & Web (5 MCPs)**
- `supabase` - Database operations
- `gmail` - Email automation with OAuth2
- `calendar` - Google Calendar integration
- `youtube-watchlater` - YouTube playlist management
- `webscraper` - Web data extraction

### **System & Files (4 MCPs)**
- `macos-automator` - Mac system control
- `filesystem` - Advanced file operations
- `wcgw` - Autonomous shell execution
- `terminal-control` - Enhanced terminal automation

### **Integration & Tools (3 MCPs)**
- `openapi` - Universal API connector
- `markitdown-simple` - Universal file converter
- `free-will` - AI autonomy experiment

## 🎙️ Voice Command Patterns

Users interact through voice commands that should be routed intelligently:

### **Database Operations** → Use `supabase` MCP
- "Show me my database tables"
- "Create a new table for users"
- "Query recent signups"

### **Creative Tasks** → Use `outsource` or `huggingface` MCPs
- "Generate a cyberpunk wallpaper"
- "Create album artwork"
- "Design a logo for my startup"

### **Code Discovery** → Use GitHub search scripts
- "Find GitHub examples of Deno auth"
- "Search for React components"

### **System Tasks** → Use `macos-automator` or `filesystem` MCPs
- "Organize my Downloads folder"
- "Take a screenshot"
- "Create a backup"

### **Email/Calendar** → Use `gmail` or `calendar` MCPs
- "Show me business emails"
- "Schedule a meeting"
- "Find emails about sponsorships"

## 🔧 Technical Architecture

### **File Structure**
```
Terminal_Power/
├── README.md              # Epic project overview
├── CLAUDE.md              # This context file
├── install.sh             # One-command installer
├── NEXT_STEPS.md          # User guidance
├── configs/
│   ├── zshrc_additions    # Shell configuration
│   ├── claude_mcp_config  # MCP setup commands
│   └── api_keys_template  # Environment template
├── scripts/
│   ├── voice-to-claude.sh # Voice transcription
│   ├── github-search.sh   # Code discovery
│   └── mcphelp           # Interactive control center
├── docs/
│   ├── MCP_GUIDE.md      # Complete MCP documentation
│   ├── VOICE_GUIDE.md    # Voice commands guide
│   ├── API_COLLECTION.md # Additional APIs
│   └── WORKFLOWS.md      # Example workflows
└── examples/
    ├── voice_diary.sh    # AI journal
    └── webapp_builder.sh # Rapid app creation
```

### **Key Scripts**
- `~/bin/mcphelp` - Interactive control center (aliased as `mcp`)
- `~/voice-to-claude.sh` - Voice transcription with Whisper API
- `~/github-search.sh` - GitHub code discovery
- `~/test-terminal-power.sh` - System diagnostics

### **API Dependencies**
- **OpenAI API** - Voice transcription (required)
- **GitHub Token** - Code search (required)
- **Google API** - Gmail/Calendar (required)
- **Supabase Token** - Database operations (required)
- **Replicate API** - Advanced AI models (optional)
- **Railway Token** - Deployment (optional)

## 🎨 Design Philosophy

### **Easy Breezy, No Fail States**
- Everything should have fallback modes
- Interactive wizards for complex setup
- Auto-repair suggestions for problems
- Beautiful UI that feels magical

### **Educational & Onboarding**
- Teach users as they go
- Show examples of what's possible
- Guide them through capabilities
- Make complex things feel simple

### **Cross-Platform & Accessible**
- Works on macOS, Linux, Windows (WSL2)
- Graceful degradation when tools unavailable
- Text fallbacks for non-interactive environments
- Clear error messages with solutions

## 🚀 Development Patterns

### **Code Style**
- Follow existing shell script patterns
- Use gum for interactive UI when available
- Provide text fallbacks for all interactive features
- Comprehensive error handling with helpful messages

### **User Experience**
- One-command installation
- Interactive onboarding flow
- Visual status indicators (✅/❌)
- Guided troubleshooting

### **API Integration**
- Test connections before using
- Provide setup wizards for complex APIs
- Show usage examples
- Handle rate limits gracefully

## 🎯 User Types & Workflows

### **Content Creators**
Focus on: YouTube management, thumbnail generation, social media automation, content research

### **Indie Developers**
Focus on: Rapid prototyping, deployment automation, database setup, code discovery

### **Music Producers**
Focus on: Ableton integration, audio processing, artwork generation, distribution

### **Digital Minimalists**
Focus on: File organization, email cleanup, automation, productivity

## 🚨 Common Issues & Solutions

### **Voice Commands Not Working**
1. Check OpenAI API key
2. Verify ffmpeg installation
3. Check microphone permissions
4. Test script manually

### **MCPs Not Loading**
1. Restart Claude Code completely
2. Check API keys are exported
3. Verify MCP commands syntax
4. Check logs in Claude Code

### **GitHub Search Failing**
1. Authenticate with `gh auth login`
2. Set GH_TOKEN environment variable
3. Test with `gh api user`

## 💡 Innovation Opportunities

### **Voice Pattern Learning**
- Learn user's common commands
- Suggest workflow optimizations
- Auto-complete voice patterns

### **Smart MCP Routing**
- Analyze task complexity
- Route to most appropriate MCP
- Combine MCPs for complex workflows

### **Workflow Automation**
- Save common command sequences
- Create custom voice shortcuts
- Share workflows with community

## 🎉 Success Metrics

Users should feel like they have:
- A personal AI assistant that understands them
- Superpowers for creative and technical work
- A terminal that feels magical, not intimidating
- The ability to build things faster than ever before

## 🔄 Continuous Improvement

- Monitor user feedback and usage patterns
- Add new MCPs as they become available
- Improve voice recognition accuracy
- Expand to new platforms and use cases

---

**Remember: Terminal Power should feel like magic, but work like engineering. Make the impossible feel inevitable.**