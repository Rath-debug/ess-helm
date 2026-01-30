#!/bin/sh
set -e

# Force unbuffered output to see logs in real-time
export PYTHONUNBUFFERED=1

echo "=========================================="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] SYNAPSE STARTUP DIAGNOSTIC"
echo "=========================================="

echo ""
echo "[DEBUG] System Information:"
echo "  - OS: $(uname -a)"
echo "  - Hostname: $(hostname)"
echo "  - Current user: $(whoami)"
echo "  - Current directory: $(pwd)"

echo ""
echo "[DEBUG] Python Environment:"
python --version 2>&1 || echo "[ERROR] Python not found!"
python -c "import sys; print(f'  - Python path: {sys.executable}')"
python -c "import psycopg2; print(f'  - psycopg2 version: {psycopg2.__version__}')" 2>&1 || echo "[WARN] psycopg2 not installed"

echo ""
echo "[DEBUG] File Sync & Permissions:"
cp -av /config/. /data/ 2>&1 | head -20 || echo "[WARN] Config copy had issues"
chown -R 991:991 /data 2>&1 && echo "  [OK] Ownership set to 991:991"
chmod -R 755 /data 2>&1 && echo "  [OK] Permissions set to 755"

echo ""
echo "[DEBUG] Configuration Files:"
for file in /data/homeserver.yaml /data/*.signing.key /data/*.log.config; do
    if [ -f "$file" ]; then
        size=$(ls -lh "$file" | awk '{print $5}')
        echo "  [OK] $(basename $file) ($size)"
    else
        echo "  [ERROR] Missing: $file"
    fi
done

echo ""
echo "[DEBUG] Database Connectivity Tests:"
echo "  - Target: postgres.railway.internal:5432"

# Try DNS resolution
if command -v getent >/dev/null 2>&1; then
    if getent hosts postgres.railway.internal >/dev/null 2>&1; then
        ip=$(getent hosts postgres.railway.internal | awk '{print $1}')
        echo "  [OK] DNS resolved to: $ip"
    else
        echo "  [WARN] Cannot resolve postgres.railway.internal"
    fi
fi

# Try TCP connection
if command -v nc >/dev/null 2>&1; then
    echo "  - Attempting TCP connection (timeout: 5s)..."
    if timeout 5 nc -zv postgres.railway.internal 5432 2>&1; then
        echo "  [OK] PostgreSQL port is reachable"
    else
        echo "  [ERROR] Cannot reach PostgreSQL (exit code: $?)"
    fi
elif command -v timeout >/dev/null 2>&1 && command -v bash >/dev/null 2>&1; then
    if timeout 5 bash -c "cat < /dev/null > /dev/tcp/postgres.railway.internal/5432" 2>&1; then
        echo "  [OK] PostgreSQL port is reachable (via bash)"
    else
        echo "  [ERROR] Cannot reach PostgreSQL (exit code: $?)"
    fi
else
    echo "  [SKIP] nc/bash not available for connectivity test"
fi

echo ""
echo "[DEBUG] Environment Variables (sanitized):"
echo "  - DATABASE_URL: $(echo $DATABASE_URL | cut -c1-20)..."
echo "  - SYNAPSE_SERVER_NAME: $SYNAPSE_SERVER_NAME"
echo "  - PATH: $PATH"

echo ""
echo "=========================================="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] STARTING SYNAPSE"
echo "=========================================="
echo ""

# Start Synapse with full error output
exec python -m synapse.app.homeserver \
    --config-path /data/homeserver.yaml \
    -v 2>&1 || { 
        echo "[FATAL] Synapse failed to start (exit code: $?)"
        exit 1
    }
