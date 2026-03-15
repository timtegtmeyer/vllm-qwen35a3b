FROM vllm/vllm-openai:latest

# Install hf_transfer for fast parallel downloads
RUN pip install --no-cache-dir hf_transfer

# Copy startup script
COPY builder/start.sh /start.sh
RUN chmod +x /start.sh

# ---------------------------------------------------------------------------
# Environment variable defaults (all overridable on the RunPod pod)
# ---------------------------------------------------------------------------
ENV MODEL_ID="Qwen/Qwen3.5-35B-A3B" \
    MAX_MODEL_LEN="32768" \
    TENSOR_PARALLEL_SIZE="1" \
    GPU_MEMORY_UTILIZATION="0.92" \
    DTYPE="bfloat16" \
    PORT="8000"

# Expose OpenAI-compatible API
EXPOSE 8000

# /start.sh: downloads model to /workspace on first run, then starts vLLM
CMD ["/start.sh"]
