FROM --platform=$BUILDPLATFORM alpine:3.15

ARG DOCKER_COMPOSE_VERSION="v2.2.2"

RUN set -e; \
    apk add --no-cache \
      bash ca-certificates curl gettext jq; \
    \
    curl --fail --location --silent "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" --output /usr/local/bin/docker-compose; \
    chmod +x /usr/local/bin/docker-compose

ENV LANG="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm" \
    ACTION="" \
    PORTAINER_USER="" \
    PORTAINER_PASSWORD="" \
    PORTAINER_AUTH_TOKEN="" \
    PORTAINER_URL="" \
    PORTAINER_STACK_NAME="" \
    PORTAINER_SERVICE_NAME="" \
    DOCKER_COMPOSE_FILE="" \
    DOCKER_COMPOSE_LINT="true" \
    ENVIRONMENT_VARIABLES_FILE="" \
    PORTAINER_ENDPOINT="1" \
    PORTAINER_PRUNE="false" \
    TIMEOUT=100 \
    AUTO_DETECT_JOB="true" \
    HTTPIE_VERIFY_SSL="yes" \
    VERBOSE_MODE="false" \
    DEBUG_MODE="false" \
    QUIET_MODE="false" \
    STRICT_MODE="false" \
    MASKED_VARIABLES="false"

COPY psu /usr/local/bin/

RUN chmod +x /usr/local/bin/psu

ENTRYPOINT ["/usr/local/bin/psu"]
