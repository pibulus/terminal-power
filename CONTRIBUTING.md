# 🤝 Contributing to Terminal Power

**Help us build the future of AI-powered terminals!**

We love your input! Whether you're reporting bugs, suggesting features, improving documentation, or contributing code - every contribution makes Terminal Power better for everyone.

---

## 🚀 **Quick Start for Contributors**

### **1. Fork & Clone**
```bash
# Fork the repo on GitHub, then:
git clone https://github.com/yourusername/terminal-power.git
cd terminal-power
```

### **2. Set Up Development Environment**
```bash
# Install Terminal Power in development mode
./install.sh

# Test your setup
mcp test
```

### **3. Make Your Changes**
```bash
# Create a feature branch
git checkout -b feature/awesome-new-feature

# Make your changes
# Test thoroughly

# Commit with clear messages
git commit -m "Add awesome new feature that does X"
```

### **4. Submit a Pull Request**
- Push your branch to GitHub
- Open a Pull Request with a clear description
- Link any related issues

---

## 🎯 **How You Can Contribute**

### **🔧 Code Contributions**
- **New MCP integrations** - Add support for more AI services
- **Platform support** - Help us support more operating systems
- **Bug fixes** - Make Terminal Power more reliable
- **Performance improvements** - Make it faster and smoother

### **📚 Documentation**
- **Improve guides** - Make setup and usage clearer
- **Add examples** - Show cool workflows and use cases
- **Translate** - Help us reach more developers worldwide
- **Video tutorials** - Create walkthroughs and demos

### **🎨 Creative Contributions**
- **Share workflows** - Show off cool Terminal Power combinations
- **Voice command patterns** - Teach the AI new tricks
- **UI improvements** - Make the interface more beautiful
- **Example projects** - Build cool things with Terminal Power

### **🧪 Testing & Feedback**
- **Test on different platforms** - macOS, Linux, WSL2
- **Report bugs** - Help us find and fix issues
- **Suggest features** - Tell us what would make Terminal Power better
- **Performance testing** - Help us optimize for different systems

---

## 📋 **Development Guidelines**

### **Code Style**
- **Shell scripts**: Follow existing patterns in `install.sh` and `mcphelp`
- **Comments**: Explain complex logic and provide examples
- **Error handling**: Always provide helpful error messages
- **Compatibility**: Test on multiple platforms when possible

### **Commit Messages**
Use clear, descriptive commit messages:
```
Add voice command pattern learning system

- Tracks user's most common voice commands
- Suggests workflow optimizations  
- Learns from usage patterns over time
- Includes auto-completion for repeated patterns

Fixes #123
```

### **Testing**
- **Test your changes** thoroughly on your platform
- **Use `mcp test`** to verify system compatibility
- **Test edge cases** - what happens when things go wrong?
- **Document any new requirements** or setup steps

---

## 🔍 **Areas We Need Help With**

### **High Priority**
- **Windows WSL2 testing** - Ensure install.sh works perfectly
- **Linux distribution support** - Test on Ubuntu, Debian, Arch, etc.
- **Error recovery** - Better auto-repair for common issues
- **MCP reliability** - Improve error handling for MCP failures

### **Medium Priority**
- **Voice command learning** - AI that learns user patterns
- **Workflow automation** - Save and replay command sequences
- **Configuration sharing** - Easy export/import of setups
- **Performance optimization** - Faster startup and execution

### **Fun Projects**
- **Deno Fresh dashboard** - Web UI for Terminal Power (v2.0)
- **Plugin marketplace** - Community-driven MCP repository
- **Voice responses** - Make Claude talk back to users
- **Team collaboration** - Share Terminal Power configs with teams

---

## 🐛 **Reporting Bugs**

### **Before Reporting**
1. **Check existing issues** - Someone might have already reported it
2. **Run `mcp test`** - Get diagnostic information
3. **Try the latest version** - Bug might already be fixed

### **Creating a Good Bug Report**
Include these details:
- **System information** (OS, version, shell)
- **Terminal Power version** or commit hash
- **Steps to reproduce** the bug
- **Expected vs actual behavior**
- **Error messages** or logs
- **Screenshots** if relevant

### **Use This Template**
```markdown
## Bug Description
Brief description of what's wrong

## System Info
- OS: macOS 14.2.1
- Shell: zsh 5.9
- Terminal Power: commit abc123

## Steps to Reproduce
1. Run `mcp`
2. Select "Voice Commands"
3. Error appears

## Expected Behavior
Should open voice command guide

## Actual Behavior
Shows error: "gum not found"

## Additional Context
- Just installed Terminal Power
- All other features work fine
```

---

## 💡 **Suggesting Features**

### **Feature Request Guidelines**
- **Search existing requests** first
- **Describe the use case** - why is this needed?
- **Propose a solution** if you have ideas
- **Consider alternatives** - are there other ways to solve this?

### **Feature Request Template**
```markdown
## Feature Request

**Problem**: What problem does this solve?
I want to use Terminal Power with my team, but there's no way to share configurations.

**Proposed Solution**: How would you solve it?
Add `mcp export` and `mcp import` commands to share configs.

**Alternatives**: What else have you considered?
- Manual copying of config files
- Documentation of setup steps

**Additional Context**: Anything else?
This would help teams onboard new developers faster.
```

---

## 🏗️ **Development Setup**

### **Prerequisites**
- **Terminal Power** installed and working
- **Git** for version control
- **Code editor** (VS Code, vim, whatever you prefer)
- **Testing environment** (multiple terminals, virtual machines helpful)

### **Project Structure**
```
Terminal_Power/
├── README.md              # Main project overview
├── CLAUDE.md              # AI context and patterns
├── install.sh             # Cross-platform installer
├── configs/               # Configuration templates
├── scripts/               # Core functionality scripts
├── docs/                  # Comprehensive documentation
├── examples/              # Example workflows and use cases
└── tests/                 # (Future) Automated tests
```

### **Key Files to Understand**
- **`install.sh`** - Main installer with cross-platform support
- **`scripts/mcphelp`** - Interactive control center
- **`scripts/voice-to-claude.sh`** - Voice transcription system
- **`CLAUDE.md`** - AI context for intelligent MCP routing

---

## 🎉 **Recognition**

### **Contributors**
All contributors will be:
- **Listed in README** with their contributions
- **Mentioned in release notes** for significant contributions
- **Given credit** in documentation they help create

### **Maintainer Path**
Regular contributors who show good judgment and helpful contributions may be invited to become maintainers with commit access.

---

## 📞 **Get Help**

### **Stuck? Need Guidance?**
- **Open a Discussion** on GitHub for questions
- **Join our community** (links in README)
- **Ask in Issues** if you're working on a specific bug/feature

### **Quick Questions**
For quick questions about development, feel free to:
- Comment on relevant issues
- Open a draft PR with your work-in-progress
- Ask in the discussions section

---

## 🌟 **Thank You!**

Terminal Power exists because people like you care about making development better. Every contribution, no matter how small, helps us build something amazing together.

**Let's make terminals magical for everyone!** 🤖⚡

---

*Remember: The best contribution is the one you're excited to make. If you have an idea, go for it!*