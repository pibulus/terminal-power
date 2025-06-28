#!/bin/bash
# Deno Deploy Tools - Terminal Power Deploy Pack
# Streamlined deployment for Deno+Fresh projects

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Check if deployctl is installed
check_deployctl() {
    if ! command -v deployctl >/dev/null 2>&1; then
        echo -e "${RED}❌ deployctl not found${NC}"
        echo ""
        echo "Install Deno Deploy CLI:"
        echo "  deno install -A --global --name deployctl jsr:@deno/deployctl"
        echo ""
        return 1
    fi
}

# Get current project info
get_project_info() {
    local current_dir=$(basename "$PWD")
    
    # Try to find existing project
    local projects=$(deployctl projects list 2>/dev/null | grep -E "^\s+\w" | awk '{print $1}')
    
    # Look for project matching directory name
    local matching_project=""
    while read -r project; do
        if [[ "$project" == *"$current_dir"* ]] || [[ "$current_dir" == *"$project"* ]]; then
            matching_project="$project"
            break
        fi
    done <<< "$projects"
    
    echo "$matching_project"
}

# Deploy current project
deploy_current() {
    local project_name="$1"
    local entry_point="${2:-main.ts}"
    
    echo -e "${BLUE}🚀 Deploying current project...${NC}"
    echo ""
    
    if [[ -z "$project_name" ]]; then
        # Try to auto-detect project
        project_name=$(get_project_info)
        
        if [[ -z "$project_name" ]]; then
            echo -e "${YELLOW}No matching project found.${NC}"
            echo ""
            
            # Show available projects
            echo "Available projects:"
            deployctl projects list | grep -E "^\s+\w" | awk '{print "  " $1}'
            echo ""
            
            read -p "Enter project name (or press Enter to create new): " project_name
            
            if [[ -z "$project_name" ]]; then
                # Create new project
                local dir_name=$(basename "$PWD")
                project_name="${dir_name}-$(date +%s)"
                echo -e "${BLUE}Creating new project: $project_name${NC}"
                deployctl projects create "$project_name"
            fi
        else
            echo -e "${GREEN}Found matching project: $project_name${NC}"
        fi
    fi
    
    # Find entry point
    if [[ ! -f "$entry_point" ]]; then
        if [[ -f "main.ts" ]]; then
            entry_point="main.ts"
        elif [[ -f "main.js" ]]; then
            entry_point="main.js"
        elif [[ -f "mod.ts" ]]; then
            entry_point="mod.ts"
        elif [[ -f "index.ts" ]]; then
            entry_point="index.ts"
        else
            echo -e "${RED}❌ No entry point found${NC}"
            echo "Looking for: main.ts, main.js, mod.ts, index.ts"
            return 1
        fi
    fi
    
    echo -e "${BLUE}📁 Entry point: $entry_point${NC}"
    echo -e "${BLUE}🎯 Project: $project_name${NC}"
    echo ""
    
    # Deploy
    echo -e "${YELLOW}⚡ Deploying...${NC}"
    if deployctl deploy --project="$project_name" "$entry_point"; then
        echo ""
        echo -e "${GREEN}🎉 Deployment successful!${NC}"
        echo ""
        echo -e "${BLUE}🔗 Your app is live at:${NC}"
        echo "   https://$project_name.deno.dev"
        echo ""
        
        # Voice response if available
        if command -v ~/Terminal_Power/scripts/voice-response.sh >/dev/null 2>&1; then
            ~/Terminal_Power/scripts/voice-response.sh "Deployment successful! Your app is now live."
        fi
    else
        echo ""
        echo -e "${RED}❌ Deployment failed${NC}"
        
        # Voice response
        if command -v ~/Terminal_Power/scripts/voice-response.sh >/dev/null 2>&1; then
            ~/Terminal_Power/scripts/voice-response.sh "Deployment failed. Please check the logs."
        fi
        return 1
    fi
}

# Create new project and deploy
deploy_new() {
    local project_name="$1"
    local template="${2:-fresh}"
    
    if [[ -z "$project_name" ]]; then
        echo "Usage: deploy-new <project-name> [template]"
        echo "Templates: fresh, vanilla, api"
        return 1
    fi
    
    echo -e "${BLUE}🆕 Creating new project: $project_name${NC}"
    echo ""
    
    # Create project on Deno Deploy
    if deployctl projects create "$project_name"; then
        echo -e "${GREEN}✅ Project created on Deno Deploy${NC}"
    else
        echo -e "${RED}❌ Failed to create project${NC}"
        return 1
    fi
    
    # Create local project
    case "$template" in
        "fresh")
            echo -e "${BLUE}🍃 Creating Fresh project...${NC}"
            deno run -A -r https://fresh.deno.dev "$project_name"
            cd "$project_name"
            ;;
        "vanilla")
            echo -e "${BLUE}📁 Creating vanilla Deno project...${NC}"
            mkdir "$project_name"
            cd "$project_name"
            cat > main.ts << 'EOF'
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";

const handler = (request: Request): Response => {
  return new Response("Hello from Deno Deploy! 🦕", {
    headers: { "Content-Type": "text/plain" },
  });
};

serve(handler);
EOF
            ;;
        "api")
            echo -e "${BLUE}🔧 Creating API project...${NC}"
            mkdir "$project_name"
            cd "$project_name"
            cat > main.ts << 'EOF'
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";

const handler = async (request: Request): Promise<Response> => {
  const url = new URL(request.url);
  
  if (url.pathname === "/api/hello") {
    return new Response(JSON.stringify({ 
      message: "Hello from API!",
      timestamp: new Date().toISOString()
    }), {
      headers: { "Content-Type": "application/json" },
    });
  }
  
  return new Response("API Server Running 🚀", {
    headers: { "Content-Type": "text/plain" },
  });
};

serve(handler);
EOF
            ;;
        *)
            echo -e "${RED}❌ Unknown template: $template${NC}"
            return 1
            ;;
    esac
    
    # Deploy immediately
    echo ""
    echo -e "${BLUE}🚀 Deploying new project...${NC}"
    deploy_current "$project_name"
}

# Show deployment logs
show_logs() {
    local project_name="$1"
    
    if [[ -z "$project_name" ]]; then
        project_name=$(get_project_info)
        
        if [[ -z "$project_name" ]]; then
            echo "Available projects:"
            deployctl projects list | grep -E "^\s+\w" | awk '{print "  " $1}'
            echo ""
            read -p "Enter project name: " project_name
        fi
    fi
    
    if [[ -n "$project_name" ]]; then
        echo -e "${BLUE}📋 Showing logs for: $project_name${NC}"
        echo ""
        deployctl logs --project="$project_name"
    fi
}

# Show project info and stats
show_project_info() {
    local project_name="$1"
    
    if [[ -z "$project_name" ]]; then
        project_name=$(get_project_info)
        
        if [[ -z "$project_name" ]]; then
            echo -e "${BLUE}📊 All Projects:${NC}"
            deployctl projects list
            return
        fi
    fi
    
    echo -e "${BLUE}📊 Project Info: $project_name${NC}"
    echo ""
    echo -e "${GREEN}🔗 URL:${NC} https://$project_name.deno.dev"
    echo ""
    
    # Show recent deployments (if supported)
    echo -e "${BLUE}📈 Recent Activity:${NC}"
    deployctl logs --project="$project_name" | head -20
}

# Main function
main() {
    # Check prerequisites
    check_deployctl || return 1
    
    case "${1:-}" in
        "new")
            deploy_new "$2" "$3"
            ;;
        "logs")
            show_logs "$2"
            ;;
        "info"|"status")
            show_project_info "$2"
            ;;
        "list")
            echo -e "${BLUE}📋 Your Deno Deploy Projects:${NC}"
            echo ""
            deployctl projects list
            ;;
        "")
            # Default: deploy current project
            deploy_current
            ;;
        *)
            echo -e "${BLUE}🚀 Deno Deploy Tools${NC}"
            echo ""
            echo "Commands:"
            echo "  deploy                    - Deploy current project"
            echo "  deploy new <name> [type]  - Create & deploy new project"
            echo "  deploy logs [project]     - Show deployment logs"
            echo "  deploy info [project]     - Show project info"
            echo "  deploy list               - List all projects"
            echo ""
            echo "Templates for new projects:"
            echo "  fresh                     - Deno Fresh app (default)"
            echo "  vanilla                   - Basic Deno server"
            echo "  api                       - JSON API server"
            echo ""
            echo "Examples:"
            echo "  deploy                    # Deploy current directory"
            echo "  deploy new my-app fresh   # Create Fresh app and deploy"
            echo "  deploy logs               # Show logs for current project"
            ;;
    esac
}

# Run main function
main "$@"