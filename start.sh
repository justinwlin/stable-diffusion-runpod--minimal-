#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

# Set workspace directory from env or default
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"

# Start nginx service
start_nginx() {
    echo "Starting Nginx service..."
    service nginx start
}

# Execute script if exists
execute_script() {
    local script_path=$1
    local script_msg=$2
    if [[ -f ${script_path} ]]; then
        echo "${script_msg}"
        bash ${script_path}
    fi
}

# Setup ssh
setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Setting up SSH..."
        mkdir -p ~/.ssh
        echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
        chmod 700 -R ~/.ssh
        # Generate SSH host keys if not present
        generate_ssh_keys
        service ssh start
        echo "SSH host keys:"
        cat /etc/ssh/*.pub
    fi
}

# Generate SSH host keys
generate_ssh_keys() {
    ssh-keygen -A
}

# Export env vars
export_env_vars() {
    echo "Exporting environment variables..."
    printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment
    echo 'source /etc/rp_environment' >> ~/.bashrc
}

# Start jupyter lab
start_jupyter() {
    echo "Starting Jupyter Lab..."
    mkdir -p "$WORKSPACE_DIR" && \
    cd / && \
    nohup jupyter lab --allow-root --no-browser --port=8888 --ip=* --NotebookApp.token='' --NotebookApp.password='' --FileContentsManager.delete_to_trash=False --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.allow_origin=* --ServerApp.preferred_dir="$WORKSPACE_DIR" &> /jupyter.log &
    echo "Jupyter Lab started without a password"
}

# Setup and start Stable Diffusion WebUI
start_webui() {
    echo "Setting up Stable Diffusion WebUI..."
    cd /workspace
    
    # Clone repo if it doesn't exist
    if [ ! -d "stable-diffusion-webui" ]; then
        echo "Cloning Stable Diffusion WebUI repository..."
        git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
    fi
    
    cd stable-diffusion-webui
    
    # Set environment variables that webui.sh would normally set
    export PYTORCH_CUDA_ALLOC_CONF="garbage_collection_threshold:0.9,max_split_size_mb:512"
    export CUDA_MODULE_LOADING=LAZY
    export PYTHONUNBUFFERED=1
    
    # Launch WebUI - it will skip already installed packages
    echo "Starting Stable Diffusion WebUI..."
    python launch.py --listen --port 8000 --skip-torch-cuda-test --no-download-sd-model &
    echo "Stable Diffusion WebUI started on port 8000"
}

# Call Python handler if mode is serverless or both
call_python_handler() {
    echo "Calling Python handler.py..."
    python $WORKSPACE_DIR/handler.py
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

start_nginx

echo "Pod Started"

setup_ssh

case $MODE_TO_RUN in
    serverless)
        call_python_handler
        ;;
    pod)
        start_jupyter
        start_webui
        ;;
    *)
        echo "Invalid MODE_TO_RUN value: $MODE_TO_RUN. Expected 'serverless', 'pod', or 'both'."
        exit 1
        ;;
esac

export_env_vars

echo "Start script(s) finished"

sleep infinity
