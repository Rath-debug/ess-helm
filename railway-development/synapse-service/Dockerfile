FROM matrixdotorg/synapse:latest

USER root

# Copy configs
COPY homeserver.yaml /data/homeserver.yaml
COPY synapse-config/synapse-production-e979.up.railway.app.signing.key /data/synapse-production-e979.up.railway.app.signing.key
COPY synapse-config/synapse-production-e979.up.railway.app.log.config /data/synapse-production-e979.up.railway.app.log.config

# Set permissions
RUN chown -R 991:991 /data && chmod -R 755 /data

USER 991

EXPOSE 8008
