echo "=== Setting up BL WhatsApp Inbox on Cloud VM ==="

# 1. Clean broken repo if present
sudo rm -f /etc/apt/sources.list.d/docker.list

# 2. Install Docker & Git directly from Debian repositories
echo "Installing Docker and Git..."
sudo apt update
sudo apt install -y docker.io docker-compose-v2 git curl

sudo systemctl enable --now docker 2>/dev/null || sudo service docker start 2>/dev/null || true
sudo usermod -aG docker  2>/dev/null || true

# 3. Clone repository
if [ ! -d "Whatsapp_BL" ]; then
    echo "Cloning repository..."
    git clone https://github.com/praneethacsk/Whatsapp_BL.git
fi

cd Whatsapp_BL

# 4. Setup environment variables
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

# 5. Start infrastructure with Docker Compose
echo "Starting backend infrastructure..."
sudo docker compose up -d

echo "=== Infrastructure started successfully! ==="