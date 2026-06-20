#!/bin/bash
# Reasonix activation wrapper - extracts key from bashrc and runs reasonix
# Usage: ./run_reasonix.sh [model] [prompt]
set -e

# Extract API key from bashrc alias
KEY=$(grep -oP 'sk-[a-zA-Z0-9]+' /home/luoshui1/.bashrc | head -1)
if [ -z "$KEY" ]; then
    echo "ERROR: Could not extract API key from bashrc"
    exit 1
fi

export DEEPSEEK_API_KEY="$KEY"
cd /home/luoshui1/projects/yunzhuan

MODEL="${1:-deepseek-v4-flash}"
PROMPT="${2:-say hello}"

exec reasonix run --model "$MODEL" "$PROMPT"
