# vllm-qwen35a3b

RunPod serverless Docker image with the **Qwen3.5-35B-A3B** model baked in at build time. Based on `runpod/worker-v1-vllm:v2.14.0`.

The model is downloaded from HuggingFace during `docker build` (using a BuildKit secret) and stored at `/models/Qwen3.5-35B-A3B` inside the image. At runtime the vLLM handler loads from the local path — no HuggingFace access required on cold start.

Published to: `ghcr.io/timtegtmeyer/vllm-qwen35a3b:latest`

---

## Prerequisites

- Docker with **BuildKit** enabled (`DOCKER_BUILDKIT=1` or Docker >= 23 which enables it by default)
- A HuggingFace token (`HF_TOKEN`) with read access to the `Qwen/Qwen3.5-35B-A3B` model

---

## Build & push

```bash
# Build (uses local SSD cache via --cache-from / --cache-to)
make build

# Push to GHCR
make push

# Build + push in one step
make build push
```

The build passes `HF_TOKEN` as a BuildKit secret so it never appears in the image layers:

```bash
docker buildx build \
  --secret id=HF_TOKEN,env=HF_TOKEN \
  -t ghcr.io/timtegtmeyer/vllm-qwen35a3b:latest \
  .
```

Make sure `HF_TOKEN` is set in your environment before running `make build`.

---

## Default vLLM parameters

These are baked into `local_model_args.json` and applied at container startup:

| Parameter | Value |
|---|---|
| `MAX_MODEL_LEN` | `32768` |
| `GPU_MEMORY_UTILIZATION` | `0.92` |
| `MAX_NUM_SEQS` | `64` |
| `MAX_CONCURRENCY` | `30` |
| `DTYPE` | `bfloat16` |
| Model path | `/models/Qwen3.5-35B-A3B` (local, no HF fetch at runtime) |

---

## Overriding parameters via RunPod endpoint env vars

All vLLM parameters can be overridden by setting environment variables on the RunPod serverless endpoint (under **Endpoint → Settings → Environment Variables**):

```
MAX_MODEL_LEN=16384
GPU_MEMORY_UTILIZATION=0.88
MAX_NUM_SEQS=32
MAX_CONCURRENCY=20
```

Changes take effect on the next worker cold start.

---

## Enabling thinking mode

Thinking mode (chain-of-thought reasoning) is **off by default**. To enable it, set these two env vars on the RunPod endpoint:

```
ENABLE_REASONING=true
REASONING_PARSER=deepseek_r1
```

This activates the vLLM reasoning parser compatible with Qwen3 thinking-mode output. The `<think>...</think>` blocks will be parsed and returned separately from the main response content.

---

## How it works

1. **Build time**: `docker build` downloads the full model weights from HuggingFace using the `HF_TOKEN` secret and stores them at `/models/Qwen3.5-35B-A3B`.
2. **`local_model_args.json`**: tells the RunPod vLLM handler to load from the local path instead of pulling from HuggingFace, and sets the default serving parameters.
3. **Runtime**: the RunPod worker starts vLLM pointing at `/models/Qwen3.5-35B-A3B` — cold start is faster since no model download is needed.
