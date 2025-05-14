#!/bin/bash

# Check if Docker image name is provided as argument
if [ -z "$1" ]; then
  echo "Error: Docker image name is required"
  echo "Usage: $0 <docker-image-name>"
  exit 1
fi

DOCKER_IMAGE=$1

# Set a default directory if X_HEEP_DIR is not defined
if [ -z "${X_HEEP_DIR}" ]; then
  X_HEEP_DIR=$(pwd)
  echo "X_HEEP_DIR was not defined, using current directory: ${X_HEEP_DIR}"
fi

# Detect operating system
OS=$(uname -s)
echo "Detected operating system: $OS"
echo "Using Docker image: $DOCKER_IMAGE"

if [ "$OS" = "Darwin" ]; then
  # ----- macOS with XQuartz -----
  # Check if XQuartz is running
  if ! ps aux | grep -v grep | grep -q XQuartz; then
    echo "XQuartz is not running. Starting XQuartz..."
    open -a XQuartz
    # Wait for XQuartz to fully start
    echo "Waiting for XQuartz to start completely..."
    sleep 10
  fi

  # Verify that XQuartz has actually started
  if ! ps aux | grep -v grep | grep -q XQuartz; then
    echo "Error: XQuartz did not start correctly. Launch it manually and try again."
    exit 1
  fi

  # Determine host IP for macOS
  IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
  if [ -z "$IP" ]; then
    IP=$(ifconfig en1 | grep inet | awk '$1=="inet" {print $2}')
  fi
  if [ -z "$IP" ]; then
    echo "Error: Could not determine IP address. Check your network connection."
    exit 1
  fi
  echo "Using IP address: $IP"

  # Configure XQuartz to accept connections
  defaults write org.macosforge.xquartz.X11 nolisten_tcp 0

  # Set display for macOS
  export DISPLAY=:0

  # Allow access to X display
  xhost + $IP

  # Run the container
  echo "Starting Docker container..."
  docker run -it --rm \
    -e DISPLAY=$IP:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "${X_HEEP_DIR}":/workspace/x-heep \
    --name heep-container \
    $DOCKER_IMAGE

  # Restore security settings
  xhost - $IP

elif [[ "$OS" = "MINGW"* ]] || [[ "$OS" = "MSYS"* ]] || [ "$OS" = "Windows_NT" ]; then
  # ----- Windows with Xming -----
  echo "Setting up for Windows with Xming..."

  # Check if Xming is running
  if ! tasklist | grep -q "Xming.exe"; then
    echo "Xming does not appear to be running. Make sure Xming is started."
    echo "If not installed, download it from: https://sourceforge.net/projects/xming/"
    read -p "Press any key after starting Xming..." -n1 -s
    echo ""
  fi

  # Get Windows IP address
  IP=$(ipconfig | grep -m 1 "IPv4" | awk '{print $NF}')
  if [ -z "$IP" ]; then
    echo "Could not automatically determine IP, please enter it manually:"
    read -p "IP Address: " IP
  fi
  echo "Using IP address: $IP"

  # Set DISPLAY for Windows (typically :0)
  export DISPLAY=$IP:0

  # Convert Windows path to Docker format
  if command -v cygpath &> /dev/null; then
    X_HEEP_DIR_DOCKER=$(cygpath -w "$X_HEEP_DIR" | sed 's/\\/\//g')
  else
    X_HEEP_DIR_DOCKER=$X_HEEP_DIR
  fi
  echo "Mounting directory: $X_HEEP_DIR as $X_HEEP_DIR_DOCKER"

  # Run the container
  echo "Starting Docker container..."
  docker run -it --rm \
    -e DISPLAY=$DISPLAY \
    -v "${X_HEEP_DIR_DOCKER}":/workspace/x-heep \
    --name heep-container \
    $DOCKER_IMAGE

else
  # ----- Linux -----
  echo "Setting up for Linux..."

  # On Linux, it generally works directly
  export DISPLAY=:0

  # Allow connections to X server
  xhost +local:docker

  # Run the container
  echo "Starting Docker container..."
  docker run -it --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "${X_HEEP_DIR}":/workspace/x-heep \
    --name heep-container \
    $DOCKER_IMAGE

  # Restore security settings
  xhost -local:docker
fi