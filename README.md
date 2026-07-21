# Dograh Backend (Production Stack)

This repository contains the Python FastAPI backend, Pipecat voice pipeline engines, Coturn WebRTC relay, and Nginx reverse proxy.

## Deployment Instructions (GCP VM)

1. **Clone to VM**:
   ```bash
   git clone https://github.com/your-org/dograh-backend.git
   cd dograh-backend
   ```

2. **Create Production `.env`**:
   Copy `.env.example` to `.env` and fill in your Supabase connection string and GCS HMAC keys:
   ```bash
   cp .env.example .env
   nano .env
   ```

3. **Start Production Containers**:
   ```bash
   docker-compose up -d
   ```

4. **Verify Deployment**:
   Visit `https://api.yourdomain.com/api/v1/health` in your browser.
