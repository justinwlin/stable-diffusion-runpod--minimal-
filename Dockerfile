# Use RunPod base image (configurable via build arg)
ARG BASE_IMAGE=runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04
FROM ${BASE_IMAGE}

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    MODE_TO_RUN=${MODE_TO_RUN:-pod} \
    WORKSPACE_DIR=/app

# Set working directory
WORKDIR $WORKSPACE_DIR

# Install system dependencies
RUN apt update && \
    apt install -y git wget libgl1 libglib2.0-0 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Pre-install Python packages that WebUI needs
RUN pip install --no-cache-dir \
        GitPython \
        Pillow \
        accelerate \
        basicsr \
        blendmodes \
        clean-fid \
        diskcache \
        einops \
        facexlib \
        "fastapi>=0.90.1" \
        gfpgan \
        "gradio==3.41.2" \
        httpcore \
        httpx \
        inflection \
        jsonmerge \
        kornia \
        lark \
        numpy \
        omegaconf \
        open-clip-torch \
        opencv-contrib-python \
        "pillow-avif-plugin==1.4.3" \
        piexif \
        "protobuf==3.20.0" \
        psutil \
        pydantic \
        "pytorch_lightning==1.9.4" \
        realesrgan \
        requests \
        resize-right \
        safetensors \
        "scikit-image>=0.19" \
        timm \
        tomesd \
        torch \
        torchdiffeq \
        torchsde \
        torchvision \
        "transformers==4.30.2" \
        xformers

# Install RunPod SDK (minimal dependencies)
RUN pip install --no-cache-dir runpod

# Copy essential files
COPY handler.py start.sh ./

# Make start script executable
RUN chmod +x start.sh

# Run the start script
CMD ["./start.sh"]