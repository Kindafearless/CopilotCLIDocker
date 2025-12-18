# Setup script for AWS Copilot CLI Docker container (PowerShell)

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "AWS Copilot CLI Docker Setup" -ForegroundColor Cyan
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

# Verify the installation
Write-Host "Verifying installation..." -ForegroundColor Yellow
Write-Host ""
Write-Host "AWS Copilot CLI version:" -ForegroundColor Cyan
docker run --rm copilot-cli copilot --version
Write-Host ""
Write-Host "AWS CLI version:" -ForegroundColor Cyan
docker run --rm copilot-cli aws --version
Write-Host ""

# Check for AWS credentials
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "AWS Credentials Check" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

$awsDir = "$env:USERPROFILE\.aws"
if (Test-Path $awsDir) {
    Write-Host "✓ AWS credentials directory found at $awsDir" -ForegroundColor Green
    Write-Host ""
    Write-Host "Testing AWS credentials..." -ForegroundColor Yellow
    $result = docker run --rm -v "${awsDir}:/home/copilot-user/.aws:ro" copilot-cli aws sts get-caller-identity 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host $result
        Write-Host ""
        Write-Host "✓ AWS credentials are valid" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠ Could not verify AWS credentials. You may need to configure them." -ForegroundColor Yellow
        Write-Host "  Run: aws configure"
    }
} else {
    Write-Host "⚠ No AWS credentials found at $awsDir" -ForegroundColor Yellow
    Write-Host "  Please configure AWS CLI on your host machine first:"
    Write-Host "  Run: aws configure"
}

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Add the following to your PowerShell profile (`$PROFILE):" -ForegroundColor Yellow
Write-Host ""
Write-Host @"
function Invoke-Copilot {
    docker run -it --rm ``
        -v "`$env:USERPROFILE\.aws:/home/copilot-user/.aws:ro" ``
        -v "`${PWD}:/workspace" ``
        copilot-cli copilot `$args
}
Set-Alias -Name copilot -Value Invoke-Copilot
"@ -ForegroundColor White
Write-Host ""
Write-Host "Then reload your profile: . `$PROFILE" -ForegroundColor Yellow
Write-Host ""
Write-Host "Usage examples:" -ForegroundColor Yellow
Write-Host "  copilot --version       # Check version"
Write-Host "  copilot init            # Initialize a new application"
Write-Host "  copilot deploy          # Deploy your application"
Write-Host "  copilot app ls          # List applications"
Write-Host "  copilot svc logs        # View service logs"
Write-Host ""
