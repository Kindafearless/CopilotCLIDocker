# GitHub Copilot CLI Docker Container

A Docker container for running [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli/) in an isolated, portable environment.

## Overview

GitHub Copilot CLI provides three main commands:
- `??` - Translates natural language into shell commands
- `git?` - Translates natural language into git commands
- `gh?` - Translates natural language into GitHub CLI commands

This Docker setup allows you to run Copilot CLI without installing Node.js or npm on your host machine.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- A GitHub account with [Copilot access](https://github.com/features/copilot)

## Quick Start

### 1. Build the Container

```bash
# Clone this repository
git clone https://github.com/Kindafearless/CopilotCLIDocker.git
cd CopilotCLIDocker

# Build the Docker image
docker build -t copilot-cli .
```

### 2. Authenticate with GitHub Copilot

Before using the CLI, you need to authenticate:

```bash
docker run -it --rm \
  -v copilot-config:/home/node/.config/github-copilot \
  copilot-cli github-copilot-cli auth
```

This will:
1. Display a device code
2. Open a URL where you enter the code
3. Store your authentication token in a Docker volume for persistence

### 3. Set Up Shell Aliases

Add these aliases to your shell configuration file (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

#### Bash / Zsh

```bash
# GitHub Copilot CLI aliases
alias '??'='docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v "$(pwd)":/workspace copilot-cli github-copilot-cli what-the-shell'
alias 'git?'='docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v "$(pwd)":/workspace copilot-cli github-copilot-cli git-assist'
alias 'gh?'='docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v "$(pwd)":/workspace copilot-cli github-copilot-cli gh-assist'

# Optional: Direct copilot-cli access
alias copilot-cli='docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v "$(pwd)":/workspace copilot-cli github-copilot-cli'
```

#### PowerShell (Windows)

Add to your PowerShell profile (`$PROFILE`):

```powershell
# GitHub Copilot CLI functions
function Invoke-CopilotShell {
    docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v "${PWD}:/workspace" copilot-cli github-copilot-cli what-the-shell $args
}
function Invoke-CopilotGit {
    docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v "${PWD}:/workspace" copilot-cli github-copilot-cli git-assist $args
}
function Invoke-CopilotGH {
    docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v "${PWD}:/workspace" copilot-cli github-copilot-cli gh-assist $args
}

# Set aliases
Set-Alias -Name '??' -Value Invoke-CopilotShell
Set-Alias -Name 'git?' -Value Invoke-CopilotGit
Set-Alias -Name 'gh?' -Value Invoke-CopilotGH
```

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

Once aliases are set up, you can use natural language to generate commands:

```bash
# Shell commands
?? list all files larger than 10MB

# Git commands
git? undo my last commit but keep the changes

# GitHub CLI commands
gh? create a new issue with the title "Bug fix needed"
```

## Docker Desktop Management

### View Running Containers

1. Open Docker Desktop
2. Go to the "Containers" tab
3. You'll see `copilot-cli` containers when running commands

### Managing the Config Volume

The authentication token is stored in a Docker volume called `copilot-config`.

```bash
# List volumes
docker volume ls

# Inspect the volume
docker volume inspect copilot-config

# Remove the volume (will require re-authentication)
docker volume rm copilot-config
```

### Updating the Container

To update to the latest Copilot CLI version:

```bash
# Remove the old image
docker rmi copilot-cli

# Rebuild with the latest version
docker build --no-cache -t copilot-cli .
```

## Advanced Configuration

### Using with Docker Compose

Create a `docker-compose.yml` for easier management:

```yaml
version: '3.8'
services:
  copilot:
    build: .
    image: copilot-cli
    volumes:
      - copilot-config:/home/node/.config/github-copilot
      - .:/workspace
    stdin_open: true
    tty: true

volumes:
  copilot-config:
```

Then use:
```bash
# Build
docker-compose build

# Run
docker-compose run --rm copilot github-copilot-cli what-the-shell "your query"
```

### Custom Image Name

If you prefer a different image name:

```bash
docker build -t my-copilot-cli .
```

Then update your aliases to use `my-copilot-cli` instead of `copilot-cli`.

## Troubleshooting

### "Authentication required" error

Re-run the authentication command:
```bash
docker run -it --rm \
  -v copilot-config:/home/node/.config/github-copilot \
  copilot-cli github-copilot-cli auth
```

### Docker Desktop not running

Ensure Docker Desktop is started. On Windows/Mac, look for the Docker icon in your system tray.

### Permission denied errors

On Linux, you may need to run docker commands with `sudo` or add your user to the `docker` group:
```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

### Slow startup

The first run downloads the image. Subsequent runs should be faster. Consider keeping Docker Desktop running in the background.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - See [LICENSE](LICENSE) for details.
