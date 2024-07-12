# Set up execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Install Chocolatey if not installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# List of packages to install
$packages = @(
    "googlechrome",
    "firefox",
    "notepadplusplus",
    "vlc",
    "git",
    "7zip",
    "adobereader",
    "visualstudiocode",
    "forticlientVPN",
    "McAfee",
    "office365",
    "zoom"
)

# Install packages in parallel
$jobs = @()
foreach ($package in $packages) {
    $jobs += Start-Job -ScriptBlock {
        param ($package)
        choco install $package --version latest -y
    } -ArgumentList $package
}

# Wait for all jobs to complete
$jobs | ForEach-Object { Receive-Job -Job $_ -Wait }
