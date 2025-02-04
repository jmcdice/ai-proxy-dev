#!/usr/bin/env bash
# set -euo pipefail
set -u

# Check dependencies
for cmd in curl jq bc; do
    command -v "$cmd" &>/dev/null || { echo "Error: $cmd is required."; exit 1; }
done

# Defaults
NUM_REQUESTS=5
GATEWAY_URL="http://envoy-ai.pool-side.cc"
DELAY=1  # seconds
MODEL="gpt4"  # or "phi4"

usage() {
    cat <<EOF
Usage: $0 [-n num_requests] [-u gateway_url] [-d delay] [-m model]
  -n: Number of requests (default: $NUM_REQUESTS)
  -u: Gateway URL (default: $GATEWAY_URL)
  -d: Delay between requests in seconds (default: $DELAY)
  -m: Model to use (gpt4 or phi4) (default: $MODEL)
EOF
    exit 1
}

while getopts "n:u:d:m:h" opt; do
    case $opt in
        n) NUM_REQUESTS=$OPTARG ;;
        u) GATEWAY_URL=$OPTARG ;;
        d) DELAY=$OPTARG ;;
        m) MODEL=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

if [[ "$MODEL" != "gpt4" && "$MODEL" != "phi4" ]]; then
    echo "Error: Model must be either 'gpt4' or 'phi4'"
    exit 1
fi

if [[ "$MODEL" == "gpt4" ]]; then
    MODEL_HEADER="gpt-4o-mini"
    MODEL_BODY="gpt-4o-mini"
else
    MODEL_HEADER="phi4"
    MODEL_BODY="phi4"
fi

echo "Configuration:
  Gateway URL: $GATEWAY_URL
  Requests: $NUM_REQUESTS
  Delay: ${DELAY}s
  Model: $MODEL
"
echo "Starting tests..."

successful=0
failed=0

parse_error() {
    local response="$1"
    local err
    err=$(echo "$response" | jq -r '(.error.error.message // .error.message // empty)' || true)
    [[ -z "$err" ]] && err="Unknown error: $response"
    echo "$err"
}

make_request() {
    local attempt=$1
    echo -n "Request $attempt"

    local start_time end_time duration
    start_time=$(date +%s.%N)

    local tmp
    tmp=$(mktemp)
    # Append || true so curl failures don't exit the script
    local http_code
    http_code=$(curl -s -w "%{http_code}" -o "$tmp" \
        -H "Content-Type: application/json" \
        -H "x-ai-eg-model: $MODEL_HEADER" \
        -d "$(cat <<JSON
{
  "model": "$MODEL_BODY",
  "messages": [
    {
      "role": "user",
      "content": "What is the capital of Greece?"
    }
  ],
  "stream": false
}
JSON
)" "$GATEWAY_URL/v1/chat/completions" || true)

    end_time=$(date +%s.%N)
    duration=$(printf "%.2f" "$(echo "$end_time - $start_time" | bc)")

    echo -n " (${duration}s): "

    if [[ "$http_code" =~ ^2[0-9]{2}$ ]]; then
        echo "Success ✓ (HTTP $http_code)"
        rm -f "$tmp"
        return 0
    else
        local content
        content=$(cat "$tmp")
        rm -f "$tmp"
        echo "Failed ✗ (HTTP $http_code) - $(parse_error "$content")"
        return 1
    fi
}

for ((i=1; i<=NUM_REQUESTS; i++)); do
    if make_request "$i"; then
        ((successful++))
    else
        ((failed++))
    fi
    if (( i < NUM_REQUESTS )); then
        sleep "$DELAY"
    fi
done

echo -e "\nTest Summary:
-------------"
echo "Total: $NUM_REQUESTS, Success: $successful, Failed: $failed, Success Rate: $(( (successful * 100) / NUM_REQUESTS ))%"

