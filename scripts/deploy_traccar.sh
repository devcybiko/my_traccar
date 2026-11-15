#!/bin/bash
set -euo pipefail

CONTAINER_NAME="traccar"
IMAGE="traccar/traccar:6.17"

CONFIG="/opt/traccar/traccar.xml"
LOG_DIR="/opt/traccar/logs"
DATA_DIR="/opt/traccar/data"

# Verify required configuration exists
if [[ ! -f "$CONFIG" ]]; then
    echo "ERROR: Missing $CONFIG" >&2
    exit 1
fi

# Avoid accidentally replacing a running container
if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    echo "ERROR: Container $CONTAINER_NAME already exists." >&2
    echo "Stop and remove it explicitly before redeploying." >&2
    exit 1
fi

# Create persistent directories
mkdir -p "$LOG_DIR" "$DATA_DIR"

# Deploy Traccar
docker run -d \
    --name "$CONTAINER_NAME" \
    --hostname traccar \
    --restart unless-stopped \
    --add-host=host.docker.internal:host-gateway \
    --memory=1g \
    -p 127.0.0.1:8082:8082 \
    -v "$CONFIG:/opt/traccar/conf/traccar.xml:ro" \
    -v "$LOG_DIR:/opt/traccar/logs:rw" \
    -v "$DATA_DIR:/opt/traccar/data:rw" \
    "$IMAGE"

echo "Traccar container created."
