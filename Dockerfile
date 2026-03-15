FROM vllm/vllm-openai:latest

# Install hf_transfer for fast parallel downloads during build
RUN pip install --no-cache-dir hf_transfer huggingface_hub[cli]

# Download model weights into the image at build time
COPY builder/download_model.sh /builder/download_model.sh
RUN chmod +x /builder/download_model.sh
RUN --mount=type=secret,id=hf_token /builder/download_model.sh

# Copy startup script
COPY builder/start.sh /start.sh
RUN chmod +x /start.sh

# ---------------------------------------------------------------------------
# Environment variable defaults (all overridable on the RunPod pod)
# ---------------------------------------------------------------------------
ENV MAX_MODEL_LEN="32768" \
    TENSOR_PARALLEL_SIZE="1" \
    GPU_MEMORY_UTILIZATION="0.92" \
    DTYPE="bfloat16" \
    PORT="8000"

EXPOSE 8000

CMD ["/start.sh"]
