#!/bin/bash
# Setup script for AWS Copilot CLI Docker container

set -e

echo "==================================="
echo "AWS Copilot CLI Docker Setup"
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

# Verify the installation
echo "Verifying installation..."
echo ""
echo "AWS Copilot CLI version:"
docker run --rm copilot-cli copilot --version
echo ""
echo "AWS CLI version:"
docker run --rm copilot-cli aws --version
echo ""

# Check for AWS credentials
echo "==================================="
echo "AWS Credentials Check"
echo "==================================="
echo ""

if [ -d "$HOME/.aws" ] && [ -f "$HOME/.aws/credentials" -o -f "$HOME/.aws/config" ]; then
    echo "✓ AWS credentials directory found at ~/.aws"
    echo ""
    echo "Testing AWS credentials..."
    if docker run --rm -v "$HOME/.aws:/home/copilot-user/.aws:ro" copilot-cli aws sts get-caller-identity 2>/dev/null; then
        echo ""
        echo "✓ AWS credentials are valid"
    else
        echo ""
        echo "⚠ Could not verify AWS credentials. You may need to configure them."
        echo "  Run: aws configure"
    fi
else
    echo "⚠ No AWS credentials found at ~/.aws"
    echo "  Please configure AWS CLI on your host machine first:"
    echo "  Run: aws configure"
fi

echo ""
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Add the following alias to your ~/.bashrc or ~/.zshrc:"
echo ""
echo "alias copilot='docker run -it --rm -v ~/.aws:/home/copilot-user/.aws:ro -v \"\$(pwd)\":/workspace copilot-cli copilot'"
echo ""
echo "Then reload your shell: source ~/.bashrc (or ~/.zshrc)"
echo ""
echo "Usage examples:"
echo "  copilot --version       # Check version"
echo "  copilot init            # Initialize a new application"
echo "  copilot deploy          # Deploy your application"
echo "  copilot app ls          # List applications"
echo "  copilot svc logs        # View service logs"
echo ""
