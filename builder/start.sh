#!/bin/bash
set -e

MODEL_ID="${MODEL_ID:-Qwen/Qwen3.5-35B-A3B}"
MODEL_DIR="/workspace/models/Qwen3.5-35B-A3B"

# ---------------------------------------------------------------------------
# Authenticate with HuggingFace (needed even for public gated models)
# ---------------------------------------------------------------------------
if [ -n "$HF_TOKEN" ]; then
    huggingface-cli login --token "$HF_TOKEN" --add-to-git-credential false
fi

# ---------------------------------------------------------------------------
# Download model to network volume on first start; skip if already present
# ---------------------------------------------------------------------------
if [ ! -f "$MODEL_DIR/config.json" ]; then
    echo "[start] Model not found in $MODEL_DIR — downloading $MODEL_ID ..."
    mkdir -p "$MODEL_DIR"
    HF_HUB_ENABLE_HF_TRANSFER=1 huggingface-cli download "$MODEL_ID" \
        --local-dir "$MODEL_DIR" \
        --local-dir-use-symlinks False
    echo "[start] Download complete."
else
    echo "[start] Model already present at $MODEL_DIR — skipping download."
fi

# ---------------------------------------------------------------------------
# Build vLLM launch args from environment variables
# ---------------------------------------------------------------------------
ARGS=(
    "--model"                  "$MODEL_DIR"
    "--served-model-name"      "Qwen3.5-35B-A3B"
    "--host"                   "0.0.0.0"
    "--port"                   "${PORT:-8000}"
    "--max-model-len"          "${MAX_MODEL_LEN:-32768}"
    "--tensor-parallel-size"   "${TENSOR_PARALLEL_SIZE:-1}"
    "--gpu-memory-utilization" "${GPU_MEMORY_UTILIZATION:-0.92}"
    "--dtype"                  "${DTYPE:-bfloat16}"
    "--trust-remote-code"
)

if [ -n "$QUANTIZATION" ]; then
    ARGS+=("--quantization" "$QUANTIZATION")
fi

if [ -n "$ENABLE_CHUNKED_PREFILL" ]; then
    ARGS+=("--enable-chunked-prefill")
fi

echo "[start] Launching vLLM: python -m vllm.entrypoints.openai.api_server ${ARGS[*]}"
exec python -m vllm.entrypoints.openai.api_server "${ARGS[@]}"
