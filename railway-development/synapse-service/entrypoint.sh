#!/bin/sh
set -e

echo "[DEBUG] Starting Synapse initialization..."
echo "[DEBUG] Environment: OS=$(uname -s), Python=$(python --version 2>&1 || echo 'N/A')"

# Sync config files into /data (handles persistent volume overrides)
echo "[DEBUG] Copying config files to /data..."
cp -a /config/. /data/ || echo "[WARN] Config sync encountered issues, continuing..."

# Ensure correct ownership for synapse user
echo "[DEBUG] Setting permissions for synapse user (991:991)..."
chown -R 991:991 /data 2>/dev/null || echo "[WARN] Permission change incomplete"
chmod -R 755 /data

# Validate critical files exist
echo "[DEBUG] Validating configuration files..."
[ -f /data/homeserver.yaml ] && echo "[OK] homeserver.yaml found" || echo "[ERROR] homeserver.yaml missing!"
[ -f /data/*.signing.key ] && echo "[OK] signing key found" || echo "[ERROR] signing key missing!"
[ -f /data/*.log.config ] && echo "[OK] log config found" || echo "[ERROR] log config missing!"

# Test PostgreSQL connectivity (diagnostic only, continues if fails)
echo "[DEBUG] Testing PostgreSQL connectivity..."
if command -v nc >/dev/null 2>&1; then
    if nc -zv postgres.railway.internal 5432 2>/dev/null; then
        echo "[OK] PostgreSQL port is reachable on postgres.railway.internal:5432"
    else
        echo "[WARN] Cannot reach PostgreSQL at postgres.railway.internal:5432 - will retry on startup"
    fi
else
    echo "[INFO] netcat not available, skipping connectivity check"
fi

# Start Synapse with the expected config path
echo "[DEBUG] Starting Synapse with config: /data/homeserver.yaml"
exec python -m synapse.app.homeserver --config-path /data/homeserver.yaml
