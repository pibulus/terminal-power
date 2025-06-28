#\!/bin/bash
DOMAIN="$1"
echo "🔍 Checking $DOMAIN..."
RESPONSE=$(curl -s -X POST "https://api.porkbun.com/api/json/v3/domain/checkDomain/$DOMAIN" \
    -H "Content-Type: application/json" \
    -d "{
        \"secretapikey\": \"sk1_7c88e60e642406860ef8ab41aff65e1ed08b0c6e11825728f9340181c7bcdcb3\",
        \"apikey\": \"pk1_4ee621999e08b950a35b1903331db2f38e600f1c3f13eb757f764439debad297\"
    }")

AVAIL=$(echo "$RESPONSE" | jq -r ".response.avail")
PRICE=$(echo "$RESPONSE" | jq -r ".response.price")
REGULAR=$(echo "$RESPONSE" | jq -r ".response.regularPrice")

if [[ "$AVAIL" == "yes" ]]; then
    echo "✅ $DOMAIN is AVAILABLE\!"
    echo "💰 Registration: \$$PRICE (regular: \$$REGULAR)"
else
    echo "❌ $DOMAIN is NOT available"
fi
