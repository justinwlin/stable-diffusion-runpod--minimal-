# Stable Diffusion WebUI Docker Setup Instructions

## Prerequisites
- Docker container with Ubuntu-based image
- Root access (you're already root in Docker)
- At least 10GB of free disk space
- Sufficient RAM (8GB+ recommended)

## Setup Steps

### 1. Update System and Install Dependencies
```bash
# Update package lists
apt update

# Install Git, software-properties-common, and google-perftools (for TCMalloc)
apt install git software-properties-common google-perftools -y

# Fix Python apt module compatibility issue (if needed)
cd /usr/lib/python3/dist-packages
ln -s apt_pkg.cpython-310-x86_64-linux-gnu.so apt_pkg.cpython-311-x86_64-linux-gnu.so
ln -s apt_inst.cpython-310-x86_64-linux-gnu.so apt_inst.cpython-311-x86_64-linux-gnu.so
```

### 2. Install Python 3.10
```bash
# Add deadsnakes PPA for Python 3.10
add-apt-repository ppa:deadsnakes/ppa -y

# Update package lists again
apt update

# Install Python 3.10 with venv and development packages
apt install python3.10 python3.10-venv python3.10-dev -y
```

### 3. Clone Stable Diffusion WebUI Repository
```bash
# Clone the repository
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui

# Navigate to the directory
cd stable-diffusion-webui
```

### 4. Create Python Virtual Environment
```bash
# Create a virtual environment using Python 3.10
python3.10 -m venv venv
```

### 5. Launch the WebUI
```bash
# Launch with Docker-specific flags
./webui.sh -f --listen --port 8000 --skip-torch-cuda-test
```

## Important Flags Explained

- **`-f`**: Force run as root (required in Docker containers)
- **`--listen`**: Makes the server accessible on 0.0.0.0 (allows external connections)
- **`--port 8000`**: Sets the server port to 8000
- **`--skip-torch-cuda-test`**: Skips CUDA test (useful if running without GPU)

## Additional Options

### For GPU Support (if available)
Remove `--skip-torch-cuda-test` flag if you have NVIDIA GPU support in your Docker container.

### For CPU-only Mode
Add these flags for better CPU performance:
```bash
./webui.sh -f --listen --port 8000 --skip-torch-cuda-test --use-cpu all --precision full --no-half
```

### To Run in Background
```bash
nohup ./webui.sh -f --listen --port 8000 --skip-torch-cuda-test > webui.log 2>&1 &
```

## First Launch Notes

1. **Initial Setup Time**: The first launch will take considerable time (15-30+ minutes) as it:
   - Downloads and installs PyTorch (~2.2GB)
   - Downloads and installs other dependencies
   - Downloads the default Stable Diffusion model (~4GB)

2. **Access the WebUI**: Once running, access the interface at:
   - From the container: `http://localhost:8000`
   - From host or network: `http://<container-ip>:8000`

3. **Check Logs**: If issues arise, check the console output or log file for errors.

## Troubleshooting

### TCMalloc
TCMalloc (from google-perftools) is included in the setup to improve memory efficiency. If you still see warnings about TCMalloc, it may require additional configuration.

### Port Already in Use
If port 8000 is occupied, change to another port:
```bash
./webui.sh -f --listen --port 7860 --skip-torch-cuda-test
```

### Memory Issues
If you encounter out-of-memory errors, add:
```bash
--lowvram
# or for very limited memory:
--lowram
```

## Quick One-Liner Setup (for clean containers)

```bash
apt update && \
apt install git software-properties-common python3-apt google-perftools -y && \
cd /usr/lib/python3/dist-packages && \
ln -s apt_pkg.cpython-310-x86_64-linux-gnu.so apt_pkg.cpython-311-x86_64-linux-gnu.so 2>/dev/null && \
ln -s apt_inst.cpython-310-x86_64-linux-gnu.so apt_inst.cpython-311-x86_64-linux-gnu.so 2>/dev/null && \
add-apt-repository ppa:deadsnakes/ppa -y && \
apt update && \
apt install python3.10 python3.10-venv python3.10-dev -y && \
cd /workspace && \
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui && \
cd stable-diffusion-webui && \
python3.10 -m venv venv && \
./webui.sh -f --listen --port 8000 --skip-torch-cuda-test
```

## Security Note
Running with `--listen` exposes the WebUI to the network. In production, consider:
- Using a reverse proxy (nginx/apache)
- Adding authentication
- Restricting network access via firewall rules