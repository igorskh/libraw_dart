$prefix = "LibRaw-0.21.4"
$zipFileName = "$prefix-Win64.zip"
$downloadUrl = "https://www.libraw.org/data/$zipFileName"
$extractPath = "LibRaw-Extract"
$currentPath = Get-Location
$dllOutputPath = Join-Path $currentPath "bin"

Write-Host "Starting LibRaw download and extraction..." -ForegroundColor Green

try {
    if (!(Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath -Force
        Write-Host "Created extraction directory: $extractPath" -ForegroundColor Yellow
    }

    $zipPath = Join-Path $currentPath $zipFileName
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force


    $dllPath = Join-Path $currentPath $extractPath $prefix "bin" "libraw.dll"

    Copy-Item -Path $dllPath -Destination $dllOutputPath -Force

    Remove-Item -Path $zipPath -Force
    Remove-Item -Path $extractPath -Recurse -Force
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}