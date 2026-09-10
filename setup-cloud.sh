#!/usr/bin/env bash
set -e

echo "=== Setting up BL WhatsApp Inbox on Cloud VM ==="

# 1. Install Docker & Git if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg git
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || true
    sudo chmod a+r /etc/apt/keyrings/docker.gpg || true
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || true
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || sudo apt install -y docker.io docker-compose-v2
    sudo usermod -aG docker $USER
fi

# 2. Clone repository
if [ ! -d "Whatsapp_BL" ]; then
    echo "Cloning repository..."
    git clone https://github.com/praneethacsk/Whatsapp_BL.git
fi

cd Whatsapp_BL

# 3. Setup environment variables
if [ ! -f ".env" ]; then
    echo "Configuring .env..."
    cp .env.example .env
    JWT_SEC=$(openssl rand -base64 32)
    CENT_SEC=$(openssl rand -base64 32)
    CENT_KEY=$(openssl rand -base64 24)
    sed -i "s/JWT_SECRET=/JWT_SECRET=${JWT_SEC}/" .env
    sed -i "s/CENTRIFUGO_TOKEN_HMAC_SECRET=/CENTRIFUGO_TOKEN_HMAC_SECRET=${CENT_SEC}/" .env
    sed -i "s/CENTRIFUGO_API_KEY=development-centrifugo-api-key/CENTRIFUGO_API_KEY=${CENT_KEY}/" .env
fi

# 4. Start infrastructure with Docker Compose
echo "Starting backend infrastructure..."
sudo docker compose up -d

echo "=== Infrastructure started successfully! ==="
