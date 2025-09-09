# RunPod GPU & Serverless Base with Stable Diffusion WebUI

A minimal, efficient Docker base image for RunPod deployments that supports both GPU pods and serverless endpoints, with Stable Diffusion WebUI pre-configured.

## Quick Deploy

**RunPod Template**: https://console.runpod.io/deploy?template=a8o9svzdqg&ref=nl2r56th

## Features

- 🎨 Stable Diffusion WebUI with optimized dependencies
- 📦 Minimal base layer built on RunPod's PyTorch image
- 🔧 Jupyter Lab support
- 🌐 Network volume compatible - WebUI persists across restarts
- ⚡ Fast startup with pre-installed Python packages
- 🔄 Runtime setup - clones WebUI to /workspace for volume persistence

## Build & Deploy

```bash
# Build and push to Docker Hub
depot build -t justinrunpod/stablediffusionwebui . --push --platform linux/amd64
```

## Environment Variables

- `PUBLIC_KEY`: SSH public key for pod access (optional)

## Ports

- **8000**: Stable Diffusion WebUI
- **8888**: Jupyter Lab (pod mode only)

## Directory Structure

```
/workspace/     # Persistent workspace (network volume mountable)
  └── stable-diffusion-webui/  # WebUI cloned at runtime
```

## What Gets Started

When the container runs:
1. Jupyter Lab starts on port 8888
2. Stable Diffusion WebUI is cloned to `/workspace/` (if not already present)
3. WebUI launches on port 8000 with pre-installed dependencies
4. SSH access available if PUBLIC_KEY is provided

## Technical Details

### Base Image
Built on `runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04` with PyTorch and CUDA pre-installed.

### Pre-installed Dependencies
All Stable Diffusion WebUI dependencies are pre-installed in the Docker image for faster startup:
- Core ML libraries: PyTorch, Transformers, Diffusers
- Image processing: Pillow, OpenCV, scikit-image
- WebUI specific: Gradio, FastAPI, xformers
- And many more...

### Network Volume Support
The start.sh script clones Stable Diffusion WebUI at runtime to `/workspace/` to support RunPod network volumes, allowing models, configurations, and extensions to persist across container restarts.

## Customization

Modify `handler.py` for custom serverless logic or extend the Dockerfile for additional dependencies.

## License

MIT