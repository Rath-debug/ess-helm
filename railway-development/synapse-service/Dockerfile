FROM matrixdotorg/synapse:latest

USER root

# Copy configs
COPY homeserver.yaml /data/homeserver.yaml
COPY synapse-config/synape-production.up.railway.app.signing.key /data/synape-production.up.railway.app.signing.key
COPY synapse-config/synape-production.up.railway.app.log.config /data/synape-production.up.railway.app.log.config
COPY entrypoint.sh /entrypoint.sh

# Set permissions
RUN chown -R 991:991 /data && chmod -R 755 /data && chmod +x /entrypoint.sh

USER 991

EXPOSE 8008

# Health check - tests if Synapse responds to version endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8008/_synapse/admin/v1/server_version || exit 1

ENTRYPOINT ["/entrypoint.sh"]
