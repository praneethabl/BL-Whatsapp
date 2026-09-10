$env:Path = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";" + [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";" + $env:Path
Set-Location "D:\BLWhatsapp"

# Start PostgreSQL if not already running
$pg = Get-Process postgres -ErrorAction SilentlyContinue
if (-not $pg) {
    Write-Host "Starting PostgreSQL on port 4447..."
    Start-Process -FilePath "D:\BLWhatsapp\pgsql\bin\postgres.exe" -ArgumentList "-D", "D:\BLWhatsapp\pgsql\data" -WindowStyle Hidden
    Start-Sleep -Seconds 2
} else {
    Write-Host "PostgreSQL is already running."
}

# Start NATS if not already running
$nats = Get-Process nats-server -ErrorAction SilentlyContinue
if (-not $nats) {
    Write-Host "Starting NATS Server on port 4448..."
    Start-Process -FilePath "D:\BLWhatsapp\nats-server-v2.10.26-windows-amd64\nats-server.exe" -ArgumentList "-p", "4448", "-js" -WindowStyle Hidden
    Start-Sleep -Seconds 1
} else {
    Write-Host "NATS Server is already running."
}

# Start API
Write-Host "Starting API server on port 4445..."
Start-Process -FilePath "bun" -ArgumentList "run", "src/index.ts" -WorkingDirectory "D:\BLWhatsapp\apps\api" -WindowStyle Minimized

# Start Frontend
Write-Host "Starting Web app on http://localhost:4444..."
Start-Process -FilePath "bun" -ArgumentList "run", "dev" -WorkingDirectory "D:\BLWhatsapp\apps\web" -WindowStyle Minimized

Write-Host "`nAll services started!"
Write-Host "Web app available at: http://localhost:4444"
