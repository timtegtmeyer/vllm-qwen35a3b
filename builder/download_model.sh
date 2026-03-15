#!/bin/bash
set -e

MODEL_ID="Qwen/Qwen3.5-35B-A3B"
MODEL_DIR="/models/Qwen3.5-35B-A3B"

HF_TOKEN="$(cat /run/secrets/hf_token 2>/dev/null || echo '')"

if [ -z "$HF_TOKEN" ]; then
    echo "ERROR: hf_token secret not provided" >&2
    exit 1
fi

huggingface-cli login --token "$HF_TOKEN" --add-to-git-credential false

echo "Downloading $MODEL_ID to $MODEL_DIR ..."
mkdir -p "$MODEL_DIR"
HF_HUB_ENABLE_HF_TRANSFER=1 huggingface-cli download "$MODEL_ID" \
    --local-dir "$MODEL_DIR" \
    --local-dir-use-symlinks False

echo "Download complete."
