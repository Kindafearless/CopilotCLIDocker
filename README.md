# AWS Copilot CLI Docker Container

A Docker container for running [AWS Copilot CLI](https://aws.github.io/copilot-cli/) in an isolated, portable environment.

## Overview

AWS Copilot CLI is the official command line tool for Amazon ECS and AWS Fargate. It helps you develop, release, and operate production-ready containerized applications on AWS.

Key features:
- Initialize and deploy containerized applications to ECS/Fargate
- Manage application environments (test, staging, production)
- Set up CI/CD pipelines
- Configure load balancers, autoscaling, and more

This Docker setup allows you to run Copilot CLI without installing it directly on your host machine.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- AWS account with appropriate IAM permissions
- AWS credentials (Access Key ID and Secret Access Key)

## Quick Start

### 1. Build the Container

```bash
# Clone this repository
git clone https://github.com/Kindafearless/CopilotCLIDocker.git
cd CopilotCLIDocker

# Build the Docker image
docker build -t copilot-cli .
```

### 2. Set Up AWS Credentials

You have several options for providing AWS credentials to the container:

#### Option A: Mount your existing AWS credentials (Recommended)

If you already have AWS CLI configured on your host:

```bash
docker run -it --rm \
  -v ~/.aws:/home/copilot-user/.aws:ro \
  -v "$(pwd)":/workspace \
  copilot-cli --help
```

#### Option B: Pass credentials as environment variables

```bash
docker run -it --rm \
  -e AWS_ACCESS_KEY_ID=your_access_key \
  -e AWS_SECRET_ACCESS_KEY=your_secret_key \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -v "$(pwd)":/workspace \
  copilot-cli --help
```

#### Option C: Use AWS SSO (Recommended for organizations)

```bash
# First, configure SSO on your host
aws configure sso

# Login to SSO
aws sso login

# Run with your SSO profile (check ~/.aws/config for profile name)
docker run -it --rm -v ~/.aws:/home/copilot-user/.aws -e AWS_PROFILE=default -v "$PWD":/workspace copilot-cli --help
```

**Important for SSO:**
- Don't use `:ro` (read-only) - SSO needs to write cache files
- Always pass `-e AWS_PROFILE=your-profile-name`
- Run `aws sso login` before using the container

### 3. Set Up Shell Aliases

Add these aliases to your shell configuration file (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

#### Bash / Zsh

```bash
# AWS Copilot CLI alias for SSO users (recommended)
alias copilot='docker run -it --rm -v ~/.aws:/home/copilot-user/.aws -e AWS_PROFILE=default -v "$PWD":/workspace copilot-cli'

# Alternative: For static credentials (no SSO)
# alias copilot='docker run -it --rm -v ~/.aws:/home/copilot-user/.aws:ro -v "$PWD":/workspace copilot-cli'
```

**Note:** Replace `default` with your actual AWS profile name from `~/.aws/config`.

#### PowerShell (Windows)

Add to your PowerShell profile (`$PROFILE`):

```powershell
# AWS Copilot CLI function for SSO users
function Invoke-Copilot {
    docker run -it --rm `
        -v "$env:USERPROFILE\.aws:/home/copilot-user/.aws" `
        -e AWS_PROFILE=default `
        -v "${PWD}:/workspace" `
        copilot-cli $args
}
Set-Alias -Name copilot -Value Invoke-Copilot
```

**Note:** Replace `default` with your actual AWS profile name.

After adding the aliases, reload your shell configuration:

```bash
# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc

# PowerShell
. $PROFILE
```

## Usage Examples

Once the alias is set up, use Copilot CLI commands as normal:

```bash
# Check version
copilot --version

# Initialize a new application
copilot init

# Deploy a service
copilot deploy

# List all applications
copilot app ls

# View application status
copilot app show

# Create a new environment
copilot env init --name production

# View logs
copilot svc logs --name api

# Delete an application
copilot app delete
```

## Common Copilot Workflows

### Deploy a New Application

```bash
# Navigate to your application directory
cd my-app

# Initialize (creates copilot/ directory)
copilot init

# Follow the prompts to:
# - Name your application
# - Choose workload type (Load Balanced Web Service, Backend Service, etc.)
# - Select a Dockerfile
# - Deploy to a test environment
```

### Add a New Environment

```bash
# Create a production environment
copilot env init --name production

# Deploy the environment
copilot env deploy --name production

# Deploy your service to production
copilot deploy --env production
```

### Set Up a CI/CD Pipeline

```bash
# Initialize a pipeline
copilot pipeline init

# Deploy the pipeline to AWS
copilot pipeline deploy
```

## Docker Desktop Management

### View Running Containers

1. Open Docker Desktop
2. Go to the "Containers" tab
3. You'll see `copilot-cli` containers when running commands

### Updating the Container

To update to the latest Copilot CLI version:

```bash
# Remove the old image
docker rmi copilot-cli

# Rebuild with the latest version (use --no-cache to ensure fresh download)
docker build --no-cache -t copilot-cli .
```

### Check Installed Versions

```bash
docker run --rm copilot-cli --version
```

To check AWS CLI version, override the entrypoint:

```bash
docker run --rm --entrypoint aws copilot-cli --version
```

## Advanced Configuration

### Using with Docker Compose

A `docker-compose.yml` is included for easier management:

```bash
# Build
docker-compose build

# Run
docker-compose run --rm copilot init
```

### Using with AWS Profiles

If you have multiple AWS profiles:

```bash
docker run -it --rm \
  -v ~/.aws:/home/copilot-user/.aws:ro \
  -e AWS_PROFILE=my-profile \
  -v "$(pwd)":/workspace \
  copilot-cli app ls
```

Or add profile-specific aliases:

```bash
alias copilot-prod='docker run -it --rm -v ~/.aws:/home/copilot-user/.aws:ro -e AWS_PROFILE=production -v "$(pwd)":/workspace copilot-cli'
```

## Troubleshooting

### "cannot find module" or Node.js errors

This usually means you have an old cached image. Rebuild with:

```bash
# Remove the old image completely
docker rmi copilot-cli

# Rebuild from scratch
docker build --no-cache -t copilot-cli .
```

### "Unable to locate credentials" error

Ensure your AWS credentials are properly mounted:

```bash
# Check if credentials file exists
ls -la ~/.aws/

# Verify credentials are valid on host first
aws sts get-caller-identity
```

### "Permission denied" errors

On Linux, you may need to run docker commands with `sudo` or add your user to the `docker` group:

```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

### Docker Desktop not running

Ensure Docker Desktop is started. On Windows/Mac, look for the Docker icon in your system tray.

### Slow startup

The first run downloads the image. Subsequent runs should be faster. Consider keeping Docker Desktop running in the background.

### AWS SSO token expired

Re-authenticate with SSO on your host:

```bash
aws sso login --profile your-profile
```

## Resources

- [AWS Copilot CLI Documentation](https://aws.github.io/copilot-cli/)
- [AWS Copilot CLI GitHub](https://github.com/aws/copilot-cli)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS Fargate Documentation](https://docs.aws.amazon.com/fargate/)

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - See [LICENSE](LICENSE) for details.
