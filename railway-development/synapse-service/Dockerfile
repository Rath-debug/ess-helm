FROM matrixdotorg/synapse:latest

USER root

# Copy configs
COPY homeserver.yaml /data/homeserver.yaml
COPY synapse-config/synape-production.up.railway.app.signing.key /data/synape-production.up.railway.app.signing.key
COPY synapse-config/synape-production.up.railway.app.log.config /data/synape-production.up.railway.app.log.config

# Set permissions
RUN chown -R 991:991 /data && chmod -R 755 /data

USER 991

EXPOSE 8008
