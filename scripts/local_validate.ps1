param(
    [switch]$SkipTerraform
)

$ErrorActionPreference = "Stop"

Write-Host "Validating YAML..."
python scripts/validate_yaml.py .github gitops platform

Write-Host "Compiling Python..."
python -m compileall app scripts

Write-Host "Running application tests..."
$env:PYTHONPATH = "app"
python -m pytest app/tests -q

Write-Host "Checking whitespace..."
git diff --check

if (-not $SkipTerraform) {
    Write-Host "Checking Terraform formatting..."
    terraform fmt -check -recursive

    Write-Host "Validating Terraform dev environment..."
    Push-Location terraform/environments/dev
    try {
        terraform validate
    }
    finally {
        Pop-Location
    }
}

Write-Host "Local validation completed."
