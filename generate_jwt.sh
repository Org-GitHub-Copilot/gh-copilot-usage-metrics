#!/bin/bash

# Parameters:
# $1 - Path to the private PEM key file
# $2 - GitHub App ID
# $3 - Token duration in seconds (e.g., 600 for 10 minutes)

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <path_to_private_pem_key> <app_id> <token_duration_in_seconds>"
    exit 1
fi

# Arguments
PEM_FILE=$1
APP_ID=$2
TOKEN_DURATION=$3

# Get the current time in seconds since Epoch (for 'iat' claim)
CURRENT_TIME=$(date +%s)

# Set expiration time based on the provided duration
EXPIRY_TIME=$(($CURRENT_TIME + $TOKEN_DURATION))

# JWT Header and Payload (JSON format)
HEADER='{
  "alg": "RS256",
  "typ": "JWT"
}'

PAYLOAD="{
  \"iat\": $CURRENT_TIME,
  \"exp\": $EXPIRY_TIME,
  \"iss\": \"$APP_ID\"
}"

# Encode the header and payload to base64
ENCODED_HEADER=$(echo -n "$HEADER" | openssl base64 -e | tr -d '\n' | tr -d '=' | tr '/+' '_-' )
ENCODED_PAYLOAD=$(echo -n "$PAYLOAD" | openssl base64 -e | tr -d '\n' | tr -d '=' | tr '/+' '_-' )

# Create the unsigned token
UNSIGNED_TOKEN="$ENCODED_HEADER.$ENCODED_PAYLOAD"

# Sign the token using the private key (RS256 signature algorithm)
SIGNATURE=$(echo -n "$UNSIGNED_TOKEN" | openssl dgst -sha256 -sign "$PEM_FILE" | openssl base64 -e | tr -d '\n' | tr -d '=' | tr '/+' '_-' )

# Final JWT
JWT="$UNSIGNED_TOKEN.$SIGNATURE"

# Print the JWT
echo "Generated JWT (valid for $TOKEN_DURATION seconds):"
echo "$JWT"
