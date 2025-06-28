#!/bin/bash

# Rapid Deno + Fresh + Supabase Webapp Builder
# Voice-controlled SaaS application generator

echo "🚀 Rapid Webapp Builder - Deno + Fresh + Supabase"
echo "=================================================="
echo ""

# Function to create a new webapp project
create_webapp() {
    local project_name="$1"
    local features="$2"
    
    echo "🏗️ Creating webapp: $project_name"
    echo "Features: $features"
    echo ""
    
    # Create project directory
    mkdir -p "$project_name"
    cd "$project_name"
    
    # Initialize Deno Fresh project
    echo "📦 Initializing Deno Fresh project..."
    deno run -A -r https://fresh.deno.dev "$project_name"
    cd "$project_name"
    
    # Create basic project structure
    echo "📁 Setting up project structure..."
    mkdir -p {components,lib,types,utils,styles}
    
    # Create Supabase configuration
    echo "🗄️ Setting up Supabase configuration..."
    cat > lib/supabase.ts << 'EOF'
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const supabaseUrl = Deno.env.get("SUPABASE_URL") || ""
const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") || ""

export const supabase = createClient(supabaseUrl, supabaseKey)

// Auth helpers
export const signUp = async (email: string, password: string) => {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  })
  return { data, error }
}

export const signIn = async (email: string, password: string) => {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })
  return { data, error }
}

export const signOut = async () => {
  const { error } = await supabase.auth.signOut()
  return { error }
}

export const getCurrentUser = async () => {
  const { data: { user } } = await supabase.auth.getUser()
  return user
}
EOF
    
    # Create authentication middleware
    echo "🔐 Setting up authentication middleware..."
    cat > routes/_middleware.ts << 'EOF'
import { MiddlewareHandlerContext } from "$fresh/server.ts"
import { getCookies } from "$std/http/cookie.ts"
import { supabase } from "../lib/supabase.ts"

interface State {
  user?: any
}

export async function handler(
  req: Request,
  ctx: MiddlewareHandlerContext<State>,
) {
  const cookies = getCookies(req.headers)
  const token = cookies["sb-access-token"]
  
  if (token) {
    const { data: { user } } = await supabase.auth.getUser(token)
    ctx.state.user = user
  }
  
  return ctx.next()
}
EOF
    
    # Create login page
    echo "📝 Creating authentication pages..."
    cat > routes/login.tsx << 'EOF'
import { Head } from "$fresh/runtime.ts"
import { Handlers, PageProps } from "$fresh/server.ts"
import { signIn } from "../lib/supabase.ts"

interface Data {
  error?: string
}

export const handler: Handlers<Data> = {
  async POST(req, ctx) {
    const form = await req.formData()
    const email = form.get("email")?.toString()
    const password = form.get("password")?.toString()
    
    if (!email || !password) {
      return ctx.render({ error: "Email and password required" })
    }
    
    const { data, error } = await signIn(email, password)
    
    if (error) {
      return ctx.render({ error: error.message })
    }
    
    const headers = new Headers()
    headers.set("location", "/dashboard")
    headers.set("set-cookie", `sb-access-token=${data.session?.access_token}; Path=/; HttpOnly`)
    
    return new Response(null, {
      status: 302,
      headers,
    })
  },
}

export default function Login({ data }: PageProps<Data>) {
  return (
    <>
      <Head>
        <title>Login - My SaaS App</title>
      </Head>
      <div class="min-h-screen flex items-center justify-center bg-gray-50">
        <div class="max-w-md w-full space-y-8">
          <div>
            <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
              Sign in to your account
            </h2>
          </div>
          <form class="mt-8 space-y-6" method="POST">
            <div>
              <label htmlFor="email" class="sr-only">Email address</label>
              <input
                id="email"
                name="email"
                type="email"
                required
                class="relative block w-full px-3 py-2 border border-gray-300 rounded-md"
                placeholder="Email address"
              />
            </div>
            <div>
              <label htmlFor="password" class="sr-only">Password</label>
              <input
                id="password"
                name="password"
                type="password"
                required
                class="relative block w-full px-3 py-2 border border-gray-300 rounded-md"
                placeholder="Password"
              />
            </div>
            <button
              type="submit"
              class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
            >
              Sign in
            </button>
            {data?.error && (
              <div class="text-red-600 text-sm mt-2">{data.error}</div>
            )}
          </form>
        </div>
      </div>
    </>
  )
}
EOF
    
    # Create dashboard page
    cat > routes/dashboard.tsx << 'EOF'
import { Head } from "$fresh/runtime.ts"
import { Handlers, PageProps } from "$fresh/server.ts"

interface State {
  user?: any
}

export const handler: Handlers<any, State> = {
  GET(req, ctx) {
    if (!ctx.state.user) {
      const headers = new Headers()
      headers.set("location", "/login")
      return new Response(null, {
        status: 302,
        headers,
      })
    }
    return ctx.render({ user: ctx.state.user })
  },
}

export default function Dashboard({ data }: PageProps<{ user: any }>) {
  return (
    <>
      <Head>
        <title>Dashboard - My SaaS App</title>
      </Head>
      <div class="min-h-screen bg-gray-50">
        <nav class="bg-white shadow">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
              <div class="flex items-center">
                <h1 class="text-xl font-semibold">My SaaS App</h1>
              </div>
              <div class="flex items-center">
                <span class="text-gray-700 mr-4">Hello, {data.user.email}</span>
                <a
                  href="/logout"
                  class="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-indigo-700"
                >
                  Logout
                </a>
              </div>
            </div>
          </div>
        </nav>
        
        <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
          <div class="px-4 py-6 sm:px-0">
            <div class="border-4 border-dashed border-gray-200 rounded-lg h-96 flex items-center justify-center">
              <div class="text-center">
                <h2 class="text-2xl font-bold text-gray-900 mb-4">
                  Welcome to your dashboard!
                </h2>
                <p class="text-gray-600">
                  Your SaaS app is ready to customize.
                </p>
              </div>
            </div>
          </div>
        </main>
      </div>
    </>
  )
}
EOF
    
    # Create environment file template
    echo "⚙️ Creating environment configuration..."
    cat > .env.example << 'EOF'
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# Development
DENO_ENV=development
EOF
    
    # Create README
    echo "📚 Creating documentation..."
    cat > README.md << EOF
# $project_name

A modern SaaS application built with Deno Fresh and Supabase.

## Features

$features

## Setup

1. Copy environment variables:
   \`\`\`bash
   cp .env.example .env
   \`\`\`

2. Configure your Supabase project settings in \`.env\`

3. Run the development server:
   \`\`\`bash
   deno task start
   \`\`\`

## Project Structure

- \`routes/\` - Fresh routes and API endpoints
- \`components/\` - Reusable UI components
- \`lib/\` - Shared utilities and configurations
- \`types/\` - TypeScript type definitions
- \`utils/\` - Helper functions

## Authentication

This app includes:
- User registration and login
- Protected routes with middleware
- Session management with Supabase Auth

## Deployment

Deploy to Deno Deploy:
\`\`\`bash
deno deploy --project=$project_name
\`\`\`

Built with 🚀 Rapid Webapp Builder
EOF
    
    # Initialize Git repository
    echo "📂 Initializing Git repository..."
    git init
    echo ".env" > .gitignore
    echo "*.log" >> .gitignore
    echo ".DS_Store" >> .gitignore
    git add .
    git commit -m "Initial commit: $project_name SaaS app with Deno Fresh + Supabase"
    
    echo ""
    echo "✅ Webapp created successfully!"
    echo "📁 Project location: $(pwd)"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Set up your Supabase project at https://supabase.com"
    echo "2. Copy .env.example to .env and add your Supabase credentials"
    echo "3. Run: deno task start"
    echo "4. Visit: http://localhost:8000"
    echo ""
}

# Voice command integration
if command -v ~/voice-to-claude.sh >/dev/null 2>&1; then
    echo "🎙️ Voice commands available! Try: voice"
    echo "Example: \"Create a project management SaaS with user authentication and task boards\""
    echo ""
fi

# Interactive mode
echo "📱 Webapp Builder Options:"
echo "1. 🚀 Create new SaaS app"
echo "2. 🎙️ Use voice to describe your app"
echo "3. 📋 Show example projects"
echo "4. ❌ Exit"
echo ""

read -p "Choose an option (1-4): " choice

case $choice in
    1)
        read -p "📝 Project name: " project_name
        read -p "✨ Describe features (e.g., 'user auth, dashboard, billing'): " features
        
        if [[ -n "$project_name" ]]; then
            create_webapp "$project_name" "$features"
        else
            echo "❌ Project name required"
        fi
        ;;
    2)
        if command -v ~/voice-to-claude.sh >/dev/null 2>&1; then
            echo "🎙️ Describe your webapp idea (speaking for 10 seconds)..."
            DESCRIPTION=$(~/voice-to-claude.sh 10)
            echo "📝 Voice description: $DESCRIPTION"
            
            # Extract project name from description (simple approach)
            read -p "📝 Project name (or press Enter for 'my-saas-app'): " project_name
            project_name=${project_name:-"my-saas-app"}
            
            create_webapp "$project_name" "$DESCRIPTION"
        else
            echo "❌ Voice script not found. Please ensure ~/voice-to-claude.sh exists."
        fi
        ;;
    3)
        echo "📋 Example SaaS Projects:"
        echo ""
        echo "🎯 Project Management Tool"
        echo "   Features: User auth, task boards, team collaboration, time tracking"
        echo ""
        echo "💼 Customer CRM"
        echo "   Features: Contact management, sales pipeline, email integration, reporting"
        echo ""
        echo "📊 Analytics Dashboard"
        echo "   Features: Data visualization, user tracking, custom reports, API integration"
        echo ""
        echo "🛒 E-commerce Platform"
        echo "   Features: Product catalog, shopping cart, payment processing, order management"
        echo ""
        ;;
    4)
        echo "👋 Thanks for using Rapid Webapp Builder!"
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        ;;
esac