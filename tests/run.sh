#!/usr/bin/env bash
set -e

# Change working directory to 'tests/'
cd "$(dirname "$0")"

# Using .env file when running tests without GitLab CI
if [[ -f "dockerfiles/.env" ]]; then
  set -a
  source "dockerfiles/.env"
  set +a
fi

[[ "$TRACE" ]] && set -x

SWARM_NODE_NAME=${SWARM_NODE_NAME:-cluster}
SWARM_NODE_IP=${SWARM_NODE_IP:-$(getent hosts $SWARM_NODE_NAME | awk '{ print $1 }')}
export BASE_DOMAIN="$SWARM_NODE_IP.nip.io"
export PSU_STACK_NAME="web-app"
PSU_URL="https://portainer.$BASE_DOMAIN"
PSU_USER="admin"
PSU_PASSWORD=${PSU_PASSWORD:-"$(openssl rand -hex 50)"}

PSU_TAG=$(if [ -n "$PSU_TAG" ]; then
    eval echo "$PSU_TAG";
  else
    echo "$CI_COMMIT_SHA";
  fi)
export PSU_TAG

PSU_TAG_CORE=$(if [ -n "$PSU_TAG_CORE" ]; then
    eval echo "$PSU_TAG_CORE";
  else
    echo "core-$CI_COMMIT_SHA";
  fi)
export PSU_TAG_CORE

function psu_wrapper() {
  docker run --rm $PSU_IMAGE:$PSU_TAG "$@"
}

function psu_core_wrapper() {
  docker run --rm $PSU_IMAGE:$PSU_TAG_CORE "$@"
}

function application_exists() {
  local stack_name="$1"
  local stack_info

  stack_info=$(psu_wrapper inspect \
    --auth-token="$PSU_AUTH_TOKEN" \
    --url="$PSU_URL" \
    --name="$stack_name" \
    --insecure \
    --debug="false" \
    --verbose="false") || true

  if [ -n "$stack_info" ]; then
    echo "true"
  else
    echo "false"
  fi
}

# Source: https://stackoverflow.com/a/24067243
function version {
  echo "$@" | awk -F. '{ printf("%03d%03d%03d\n", $1,$2,$3); }';
}

# Leave Docker Swarm, if already set
docker swarm leave --force && sleep 3 | true

# Remove admin password from Docker secrets, if already set
docker secret rm psu-portainer-password | true

# Remove portainer data, if already set
docker volume rm --force portainer_psu-portainer && sleep 2 | true

# Remove web-app data, if already set
docker volume rm --force web-app_psu-php-runner && sleep 2 | true

# Init Docker Swarm
docker swarm init

# Deploy Traefik test
# Parse the Docker traefik stack file to deploy
envsubst '$TRAEFIK_VERSION,$BASE_DOMAIN' < dockerfiles/docker-stack-traefik.yml > dockerfiles/docker-stack-traefik-final.yml
docker stack deploy -c dockerfiles/docker-stack-traefik-final.yml traefik --with-registry-auth
bash -c "timeout 20 bash -c 'while ! (echo > /dev/tcp/$SWARM_NODE_NAME/443 && curl -fks --max-time 2 https://traefik.$BASE_DOMAIN) >/dev/null 2>&1; do sleep 1; done;'"

# Deploy Portainer test
# Create admin password as a Docker secret
# See: https://documentation.portainer.io/v2.0/deploy/initial/
echo -n $PSU_PASSWORD | docker secret create psu-portainer-password -

# Parse the Docker portainer stack file to deploy
envsubst '$PORTAINER_IMAGE,$PORTAINER_VERSION,$PORTAINER_COMMAND_OPTIONS,$BASE_DOMAIN' < dockerfiles/docker-stack-portainer.yml > dockerfiles/docker-stack-portainer-final.yml
docker stack deploy -c dockerfiles/docker-stack-portainer-final.yml portainer --with-registry-auth
bash -c "timeout 20 bash -c 'while ! (curl -fkLs --max-time 2 $PSU_URL) >/dev/null 2>&1; do sleep 1; done;'"

# psu version test
psu_wrapper --version | grep -E 'version v?[0-9]+\.[0-9]+\.[0-9]+'

# psu help test
# Check if 4 terms present in the help message are visible when running the command
[ "$(psu_wrapper --help | grep -E 'Usage|Arguments|Options|Available actions' | wc -l)" == "4" ]

# TODO: test 'actions' action
# TODO: test 'services' action
# TODO: test 'containers' action

# Portainer login test
PSU_AUTH_TOKEN=$(psu_wrapper login --user $PSU_USER --password $PSU_PASSWORD --url $PSU_URL --insecure)

# Add GitLab Docker registry access to Portainer
envsubst '$CI_REGISTRY_USER,$CI_REGISTRY_PASSWORD' < gitlab-registry.json > gitlab-registry-final.json
http --check-status --ignore-stdin --verify=no --timeout=10 POST "$PSU_URL/api/registries" "Authorization: Bearer $PSU_AUTH_TOKEN" @gitlab-registry-final.json

# Add local endpoint to the Portainer instance
end_point_type_param=EndpointType
if [[ "$PORTAINER_VERSION" == "latest" ]] || [ "$(version $PORTAINER_VERSION)" -ge "$(version 2.0)" ]; then
  # See: https://github.com/portainer/portainer/issues/4602#issuecomment-746819197
  end_point_type_param=EndpointCreationType
fi
http --check-status --ignore-stdin --verify=no --timeout=10 POST "$PSU_URL/api/endpoints" "Authorization: Bearer $PSU_AUTH_TOKEN" Name==local $end_point_type_param==1

# Docker system info from Portainer test
docker_info=$(psu_wrapper system:info --user $PSU_USER --password $PSU_PASSWORD --url $PSU_URL --insecure --debug false --verbose false)
[ "$(echo "$docker_info" | jq -j ".DockerRootDir")" == "/var/lib/docker" ]

# Parse the Docker compose/stack file to deploy
envsubst '$CI_REGISTRY,$CI_PROJECT_NAMESPACE,$BASE_DOMAIN,$PSU_STACK_NAME' < dockerfiles/docker-stack-web-app.yml > dockerfiles/docker-stack-web-app-final.yml

# Convert docker compose/stack file in a base64 encoded string,
# due to some limitations with Docker in Docker and volumes
# see: https://stackoverflow.com/a/55481515
docker_compose_base64="$(cat dockerfiles/docker-stack-web-app-final.yml | base64)"

# Lint the Docker compose/stack file to be deployed
lint_result=$(psu_wrapper lint --compose-file-base64 "$docker_compose_base64" --debug false --verbose false)
[ "$lint_result" == "[OK]" ]

# Stack deploy test
# Check the 'web-app' stack isn't deployed yet
[ "$(application_exists $PSU_STACK_NAME)" == "false" ]
# Deploy the 'web-app' stack
psu_core_wrapper deploy --user $PSU_USER --password $PSU_PASSWORD --url $PSU_URL --name $PSU_STACK_NAME --compose-file-base64 "$docker_compose_base64" --insecure $PORTAINER_DEPLOY_EXTRA_ARGS
[ "$(application_exists $PSU_STACK_NAME)" == "true" ]
# Ensure the deployed stack is running correctly
psu_wrapper status --user=$PSU_USER --password=$PSU_PASSWORD --url=$PSU_URL --name=$PSU_STACK_NAME --insecure --timeout=30 $PORTAINER_DEPLOY_EXTRA_ARGS
now=$(date -u +"%Y-%m-%d")
curl -fks --max-time 6 https://$PSU_STACK_NAME.$BASE_DOMAIN | grep -w "OK<br>$now"
# Ensure the deployed stack has no environment variables
stack_info=$(psu_wrapper inspect --user=$PSU_USER --password=$PSU_PASSWORD --url=$PSU_URL --name=$PSU_STACK_NAME --debug=false --verbose=false --insecure)
stack_envvars="$(echo -n "$stack_info" | jq ".Env" -jc)"
[ "$stack_envvars" == "[]" ]

# List deployed stacks with quiet mode test
stack_list="$(psu_wrapper ls --user $PSU_USER --password $PSU_PASSWORD --url $PSU_URL --insecure --debug false --verbose false --quiet)"
[ "$stack_list" == "$PSU_STACK_NAME" ]

# Convert env file in a base64 encoded string,
# due to some limitations with Docker in Docker and volumes
# see: https://stackoverflow.com/a/55481515
env_file_base64="$(cat dockerfiles/web-app.env | base64)"

# Stack update test
psu_wrapper deploy --user $PSU_USER --password $PSU_PASSWORD --url $PSU_URL --name $PSU_STACK_NAME --compose-file-base64 "$docker_compose_base64" --env-file-base64 "$env_file_base64" --insecure $PORTAINER_DEPLOY_EXTRA_ARGS
# Check the 'web-app' stack is already deployed
[ "$(application_exists $PSU_STACK_NAME)" == "true" ]
# Ensure the updated stack is running correctly
psu_wrapper status --user=$PSU_USER --password=$PSU_PASSWORD --url=$PSU_URL --name=$PSU_STACK_NAME --insecure --timeout=30 $PORTAINER_DEPLOY_EXTRA_ARGS
now=$(date -u +"%Y-%m-%d")
curl -fks --max-time 6 https://$PSU_STACK_NAME.$BASE_DOMAIN | grep -w "OK<br>$now"
# Ensure the updated stack has environment variables corresponding to the env file
stack_info=$(psu_wrapper inspect --user=$PSU_USER --password=$PSU_PASSWORD --url=$PSU_URL --name=$PSU_STACK_NAME --debug=false --verbose=false --insecure)
stack_envvars="$(echo -n "$stack_info" | jq ".Env" -jc)"
[ "$stack_envvars" != "[]" ]
env_foo_from_stack="$(echo -n "$stack_envvars" | jq ".[] | select(.name == \"FOO\") | .value" -r)"
(. dockerfiles/web-app.env && [ "$FOO" == "$env_foo_from_stack" ])
env_db_migrate_from_stack="$(echo -n "$stack_envvars" | jq ".[] | select(.name == \"DB_MIGRATE\") | .value" -r)"
(. dockerfiles/web-app.env && [ "$DB_MIGRATE" == "$env_db_migrate_from_stack" ])

# Stack remove/undeploy test
psu_wrapper rm --user $PSU_USER --password $PSU_PASSWORD --url $PSU_URL --name $PSU_STACK_NAME --insecure $PORTAINER_DEPLOY_EXTRA_ARGS
[ "$(application_exists $PSU_STACK_NAME)" == "false" ]
# Ensure the reverse proxy Traefik free the URL of the removed stack
bash -c "timeout 20 bash -c 'while ! (curl -ks --max-time 2 https://$PSU_STACK_NAME.$BASE_DOMAIN | grep -w \"404 page not found\") >/dev/null 2>&1; do sleep 1; done;'"
curl -ks --max-time 6 https://$PSU_STACK_NAME.$BASE_DOMAIN
