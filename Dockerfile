FROM alpine:3.14

ARG DOCKER_COMPOSE_VERSION_GTE=1.29.2
ARG DOCKER_COMPOSE_VERSION_LT=1.30.0

RUN set -e; \
    apk add --no-cache \
      bash ca-certificates gettext jq \
      py3-pip python3-dev libc-dev libffi-dev openssl-dev gcc make musl-dev py3-wheel; \
    \
    pip3 --no-cache-dir install "docker-compose>=${DOCKER_COMPOSE_VERSION_GTE},<${DOCKER_COMPOSE_VERSION_LT}" "httpie>=1.0.3,<1.1.0" "cryptography>=3.3.2,<3.4.0"; \
    \
    apk del python3-dev libc-dev libffi-dev openssl-dev gcc make musl-dev py3-wheel; \
    rm -rf $(find / -regex '.*\.py[co]')

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
