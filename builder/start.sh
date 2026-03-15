#!/bin/bash
set -e

MODEL_DIR="/models/Qwen3.5-35B-A3B"

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

echo "[start] Launching vLLM with model at $MODEL_DIR"
exec python -m vllm.entrypoints.openai.api_server "${ARGS[@]}"
