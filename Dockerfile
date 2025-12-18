# Dockerfile for AWS Copilot CLI
# Provides a containerized environment for running AWS Copilot CLI commands

FROM amazonlinux:2023

# Install dependencies
RUN dnf install -y \
    curl \
    unzip \
    git \
    tar \
    gzip \
    less \
    groff \
    && dnf clean all

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install AWS Copilot CLI
RUN curl -Lo /usr/local/bin/copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux \
    && chmod +x /usr/local/bin/copilot

# Create non-root user
RUN useradd -m -s /bin/bash copilot-user

# Switch to non-root user
USER copilot-user

# Set working directory
WORKDIR /workspace

# Default command shows help
CMD ["copilot", "--help"]
