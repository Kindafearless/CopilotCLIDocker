# Setup script for GitHub Copilot CLI Docker container (PowerShell)

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "GitHub Copilot CLI Docker Setup" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is available
try {
    $null = Get-Command docker -ErrorAction Stop
} catch {
    Write-Host "Error: Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
    exit 1
}

# Check if Docker daemon is running
try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -ne 0) { throw }
} catch {
    Write-Host "Error: Docker daemon is not running" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again"
    exit 1
}

Write-Host "✓ Docker is available and running" -ForegroundColor Green
Write-Host ""

# Build the image
Write-Host "Building the copilot-cli Docker image..." -ForegroundColor Yellow
docker build -t copilot-cli .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build Docker image" -ForegroundColor Red
    exit 1
}
Write-Host ""
Write-Host "✓ Image built successfully" -ForegroundColor Green
Write-Host ""

# Create the config volume if it doesn't exist
Write-Host "Creating config volume..." -ForegroundColor Yellow
docker volume create copilot-config 2>&1 | Out-Null
Write-Host "✓ Config volume ready" -ForegroundColor Green
Write-Host ""

# Authenticate
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "GitHub Copilot Authentication" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You will now be prompted to authenticate with GitHub Copilot."
Write-Host "A device code will be displayed - enter it at the URL provided."
Write-Host ""
Read-Host "Press Enter to continue with authentication"
Write-Host ""

docker run -it --rm `
    -v copilot-config:/home/node/.config/github-copilot `
    copilot-cli github-copilot-cli auth

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Add the following to your PowerShell profile ($PROFILE):" -ForegroundColor Yellow
Write-Host ""
Write-Host @"
function Invoke-CopilotShell {
    docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v "`${PWD}:/workspace" copilot-cli github-copilot-cli what-the-shell `$args
}
function Invoke-CopilotGit {
    docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v "`${PWD}:/workspace" copilot-cli github-copilot-cli git-assist `$args
}
function Invoke-CopilotGH {
    docker run -it --rm -v copilot-config:/home/node/.config/github-copilot -v "`${PWD}:/workspace" copilot-cli github-copilot-cli gh-assist `$args
}
Set-Alias -Name '??' -Value Invoke-CopilotShell
Set-Alias -Name 'git?' -Value Invoke-CopilotGit
Set-Alias -Name 'gh?' -Value Invoke-CopilotGH
"@ -ForegroundColor White
Write-Host ""
Write-Host "Then reload your profile: . `$PROFILE" -ForegroundColor Yellow
Write-Host ""
Write-Host "Usage examples:" -ForegroundColor Yellow
Write-Host "  ?? list all files larger than 10MB"
Write-Host "  git? undo my last commit"
Write-Host "  gh? create a new issue"
Write-Host ""
