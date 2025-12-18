# Dockerfile for GitHub Copilot CLI
# Provides a containerized environment for running GitHub Copilot CLI commands

FROM node:20-slim

# Set environment variables
ENV NODE_ENV=production
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

# Install dependencies and GitHub Copilot CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g @githubnext/github-copilot-cli \
    && chown -R node:node /home/node

# Switch to non-root user for security
USER node

# Create directory for GitHub Copilot config
RUN mkdir -p /home/node/.config/github-copilot

# Set working directory
WORKDIR /workspace

# Default command shows help
CMD ["github-copilot-cli", "--help"]
