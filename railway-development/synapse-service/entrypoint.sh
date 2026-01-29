#!/bin/sh
set -e

# Sync config files into /data (handles persistent volume overrides)
cp -a /config/. /data/

# Ensure correct ownership for synapse user
chown -R 991:991 /data

# Start Synapse with the expected config path
exec python -m synapse.app.homeserver --config-path /data/homeserver.yaml
