#!/bin/bash

set -euo pipefail

# CONFIGURATION TO CHANGE
# Name of the Python script to run as the entrypoint in ./build
PYTHON_SCRIPT_NAME="test-script.py"

# Static configuration - do not change below here unless needed
LOCK_FILE_NAME=version.lock
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
LOCK_FILE="$SCRIPT_DIR/$LOCK_FILE_NAME"
DOCKERFILE="$SCRIPT_DIR/build/Dockerfile"
REQUIREMENTS="$SCRIPT_DIR/build/src/requirements.txt"
SCRIPT="$SCRIPT_DIR/build/src/$PYTHON_SCRIPT_NAME"

# Compute current checksum and use it as the image name
CURRENT_HASH=$(cat "$DOCKERFILE" "$REQUIREMENTS" "$SCRIPT" | sha256sum | cut -d ' ' -f 1)
IMAGE_NAME="runner-$CURRENT_HASH"

# Check if lock file exists
if [ ! -f "$LOCK_FILE" ]; then
  echo "$LOCK_FILE_NAME not found. Creating it. Commit this to source control."
  echo "$CURRENT_HASH" >"$LOCK_FILE"
  docker build --build-arg SCRIPT_NAME="$PYTHON_SCRIPT_NAME" -t "$IMAGE_NAME" -t "runner:latest" "$SCRIPT_DIR/build"
elif [ "$CURRENT_HASH" != "$(cat "$LOCK_FILE")" ]; then
  echo "Checksum does not match. Updating $LOCK_FILE_NAME and rebuilding."
  echo "Commit this new lock file to source control."
  echo "$CURRENT_HASH" >"$LOCK_FILE"
  docker build --build-arg SCRIPT_NAME="$PYTHON_SCRIPT_NAME" -t "$IMAGE_NAME" -t "runner:latest" "$SCRIPT_DIR/build"
elif ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "Docker image '$IMAGE_NAME' not found locally. Rebuilding."
  docker build --build-arg SCRIPT_NAME="$PYTHON_SCRIPT_NAME" -t "$IMAGE_NAME" -t "runner:latest" "$SCRIPT_DIR/build"
else
  echo "No changes detected and Docker image '$IMAGE_NAME' exists. Using existing image."
fi

# Run the script inside the container with passed arguments
docker run "$IMAGE_NAME" "$@"
