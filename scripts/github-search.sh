#!/bin/bash

# 🔍 GitHub Code Search Script
# Search for useful code components and repositories

set -e

SEARCH_QUERY="$1"
SEARCH_TYPE="${2:-code}"  # code, repositories, issues, users

if [[ -z "$SEARCH_QUERY" ]]; then
    echo "Usage: $0 \"search query\" [type]"
    echo "Types: code, repositories, issues, users"
    echo ""
    echo "Examples:"
    echo "  $0 \"deno fresh auth\" code"
    echo "  $0 \"supabase middleware\" repositories" 
    echo "  $0 \"fresh components navbar\" code"
    exit 1
fi

echo "🔍 Searching GitHub for: \"${SEARCH_QUERY}\" (type: ${SEARCH_TYPE})"

case $SEARCH_TYPE in
    "code")
        # Search for code with file details
        gh api search/code -f q="${SEARCH_QUERY}" --jq '.items[] | "\(.repository.full_name)/\(.path) - \(.repository.description // "No description")\n\(.html_url)"' | head -20
        ;;
    "repositories"|"repos")
        # Search for repositories
        gh api search/repositories -f q="${SEARCH_QUERY}" --jq '.items[] | "\(.full_name) ⭐\(.stargazers_count) - \(.description // "No description")\n\(.html_url)\n"' | head -10
        ;;
    "issues")
        # Search for issues
        gh api search/issues -f q="${SEARCH_QUERY}" --jq '.items[] | "\(.title) - \(.repository_url | split("/") | .[-1])\n\(.html_url)\n"' | head -10
        ;;
    "users")
        # Search for users
        gh api search/users -f q="${SEARCH_QUERY}" --jq '.items[] | "\(.login) - \(.name // "No name")\n\(.html_url)\n"' | head -10
        ;;
    *)
        echo "❌ Invalid search type. Use: code, repositories, issues, users"
        exit 1
        ;;
esac

echo ""
echo "💡 Tip: Use specific queries like 'deno fresh filename:auth extension:ts' for better results"