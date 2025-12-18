#!/bin/bash
# Setup script for GitHub Copilot CLI Docker container

set -e

echo "==================================="
echo "GitHub Copilot CLI Docker Setup"
echo "==================================="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running"
    echo "Please start Docker Desktop and try again"
    exit 1
fi

echo "✓ Docker is available and running"
echo ""

# Build the image
echo "Building the copilot-cli Docker image..."
docker build -t copilot-cli .
echo ""
echo "✓ Image built successfully"
echo ""

# Create the config volume if it doesn't exist
echo "Creating config volume..."
docker volume create copilot-config &> /dev/null || true
echo "✓ Config volume ready"
echo ""

# Authenticate
echo "==================================="
echo "GitHub Copilot Authentication"
echo "==================================="
echo ""
echo "You will now be prompted to authenticate with GitHub Copilot."
echo "A device code will be displayed - enter it at the URL provided."
echo ""
read -p "Press Enter to continue with authentication..."
echo ""

docker run -it --rm \
    -v copilot-config:/home/node/.config/github-copilot \
    copilot-cli github-copilot-cli auth

echo ""
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Add the following aliases to your ~/.bashrc or ~/.zshrc:"
echo ""
echo "alias '??'='docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v \"\$(pwd)\":/workspace copilot-cli github-copilot-cli what-the-shell'"
echo "alias 'git?'='docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v \"\$(pwd)\":/workspace copilot-cli github-copilot-cli git-assist'"
echo "alias 'gh?'='docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v \"\$(pwd)\":/workspace copilot-cli github-copilot-cli gh-assist'"
echo ""
echo "Then reload your shell: source ~/.bashrc (or ~/.zshrc)"
echo ""
echo "Usage examples:"
echo "  ?? list all files larger than 10MB"
echo "  git? undo my last commit"
echo "  gh? create a new issue"
echo ""
