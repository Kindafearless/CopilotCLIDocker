# Dockerfile for AWS Copilot CLI
# Provides a containerized environment for running AWS Copilot CLI commands

FROM amazonlinux:2023

# Install dependencies
# Note: curl-minimal is pre-installed in AL2023, no need to install curl
RUN dnf install -y \
    unzip \
    git \
    tar \
    gzip \
    less \
    groff \
    && dnf clean all

# Install AWS CLI v2 (architecture-aware)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    fi && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install AWS Copilot CLI (architecture-aware)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl -Lo /usr/local/bin/copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl -Lo /usr/local/bin/copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux-arm64; \
    fi && \
    chmod +x /usr/local/bin/copilot

# Create non-root user
RUN useradd -m -s /bin/bash copilot-user

# Switch to non-root user
USER copilot-user

# Set working directory
WORKDIR /workspace

# Set entrypoint to the copilot binary explicitly
ENTRYPOINT ["/usr/local/bin/copilot"]

# Default command shows help
CMD ["--help"]
