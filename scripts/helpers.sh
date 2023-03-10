#!/usr/bin/env bash
set -e
[[ "$TRACE" ]] && set -x

function registry_login() {
  if [[ -n "$CI_REGISTRY_USER" ]]; then
    echo "Logging to GitLab Container Registry with CI credentials..."
    docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
    echo ""
  fi
}

function external_registry_login() {
  if [[ -n "$DOCKER_USER" ]]; then
    echo "Logging to External Registry..."
    docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD" "$DOCKER_REGISTRY"
    echo ""
  fi
}

function setup_docker() {
  if ! docker info &>/dev/null; then
    if [ -z "$DOCKER_HOST" ] && [ -n "$KUBERNETES_PORT" ]; then
      export DOCKER_HOST='tcp://localhost:2375'
    fi
  fi
}

function setup_docker_multi_arch() {
  mkdir -p ~/.docker/cli-plugins/
  current_system="$(uname -s | tr '[:upper:]' '[:lower:]')"
  current_arch="$(uname -m)"
  case $current_arch in
    armv6*) current_arch="arm-v6";;
    armv7*) current_arch="arm-v7";;
    aarch64) current_arch="arm64";;
    x86_64) current_arch="amd64";;
  esac
  curl --fail --location --silent "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.${current_system}-${current_arch}" --output ~/.docker/cli-plugins/docker-buildx
  chmod a+x ~/.docker/cli-plugins/docker-buildx
  docker context create multiarch
  docker run --privileged --rm tonistiigi/binfmt --install all
  docker buildx create --name multibuilder --use --platform $DOCKER_MULTI_ARCH multiarch
  docker buildx inspect --bootstrap
}

function git_tag_on_success() {
  local git_tag="${1:-dev}"
  local target_branch="${2:-${CI_MAIN_BRANCH:-main}}"

  if (
    [ "$CI_COMMIT_REF_NAME" == "$target_branch" ] &&
    [ -n "$GITLAB_API_TOKEN" ] &&
    [ -z "$GIT_RESET_TAG" ]
  ); then
    # wget from alpine:3.10 or docker:stable is buggy with SSL and proxy.
    # So we install curl instead, if it isn't already installed
    local curl_is_installed=$(which curl || true)
    if [ -z "$curl_is_installed" ]; then
      apk add --no-cache curl
    fi

    # (re)write Protected Tag
    curl --silent --fail --output /dev/null --request DELETE --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$CI_API_V4_URL/projects/$CI_PROJECT_ID/protected_tags/$git_tag" || true
    curl --silent --fail --output /dev/null --request DELETE --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$CI_API_V4_URL/projects/$CI_PROJECT_ID/repository/tags/$git_tag" || true
    curl --silent --show-error --fail --output /dev/null --data "tag_name=$git_tag" --data "ref=$CI_COMMIT_SHA" --fail --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$CI_API_V4_URL/projects/$CI_PROJECT_ID/repository/tags"
    curl --silent --show-error --fail --output /dev/null --data "name=$git_tag" --data "create_access_level=0" --fail --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$CI_API_V4_URL/projects/$CI_PROJECT_ID/protected_tags"
  else
    echo WARNING: \$GITLAB_API_TOKEN variable is missing
  fi
}

function registry_tag_on_success() {
  local current_registry_tag="${1:-$CI_COMMIT_SHA}"
  local target_registry_tag="${2:-dev}"
  local target_branch="${3:-${CI_MAIN_BRANCH:-main}}"
  local current_registry_image="${4:-$CI_REGISTRY_IMAGE/builds}"
  local target_registry_image="${5:-$CI_REGISTRY_IMAGE}"
  local target_external_registry_image="${6:-$DOCKER_REGISTRY_IMAGE}"

  if [ "$CI_COMMIT_REF_NAME" == "$target_branch" ]; then
    echo -e "FROM --platform=\$BUILDPLATFORM $current_registry_image:$current_registry_tag
    " > Dockerfile.tmp
    docker buildx build --compress --push --platform $DOCKER_MULTI_ARCH --tag "$target_registry_image:$target_registry_tag" $(if [ -n "$DOCKER_REGISTRY" ] && [ -n "$target_external_registry_image" ]; then echo "--tag $target_external_registry_image:$target_registry_tag"; fi) --file Dockerfile.tmp .
    rm -f Dockerfile.tmp
  fi
}

# Reset the git repository to the target tag
#
# First argument pass to this function or the `GIT_RESET_TAG` CI variable
# must be set
#   git_reset_from_tag dev
# or:
#   GIT_RESET_TAG=dev
#   git_reset_from_tag
function git_reset_from_tag() {
  local git_target_tag="${1:-$GIT_RESET_TAG}"

  if (
    [ "$CI_PIPELINE_SOURCE" == "schedule" ] &&
    [ -n "$git_target_tag" ] && [ "$GIT_STRATEGY" != "none" ] &&
    [ -z "$CI_COMMIT_TAG" ]
  ); then
    # Get specific tag
    git reset --hard $git_target_tag
    export CI_COMMIT_SHA=$(git rev-parse HEAD)
    export CI_COMMIT_SHORT_SHA=$(git rev-parse --short HEAD)
  else
    echo NOTICE: Not a Scheduling Pipeline, skip the git tag reset stuff... # debug
  fi
}

# Get latest stable semantic versioning git tag
# from a specific git branch
#
# First argument pass to this function or the `CI_COMMIT_REF_NAME` CI variable
# must be set
#   get_git_last_stable_tag 1-0-stable
#   -> "v1.0.3"
# or:
#   CI_COMMIT_REF_NAME=1-0-stable
#   get_git_last_stable_tag
#   -> "v1.0.3"
#
# see: https://semver.org
function get_git_last_stable_tag() {
  local target_branch="${1:-$CI_COMMIT_REF_NAME}"

  git fetch origin $target_branch
  git checkout -f -q $target_branch
  echo "$(git tag --merged $target_branch | grep -w '^v[0-9]\+\.[0-9]\+\.[0-9]\+$' | sort -r -V | head -n 1)"
}

# Useful for updating Docker images, on release/stable branches, but not the psu code
# See: https://docs.gitlab.com/ce/workflow/gitlab_flow.html#release-branches-with-gitlab-flow
# You can create a scheduled pipeline with a targeted git branch ("main", "1-0-stable", ...)
# and the CI variables below:
#   "GIT_RESET_LAST_STABLE_TAG=true"
#   "DOCKER_CACHE_DISABLED=true"
#   "TEST_DISABLED=" # no value to unset this variable
# See: https://gitlab.com/help/user/project/pipelines/schedules
function git_reset_from_last_stable_tag() {
  if [ "$GIT_RESET_LAST_STABLE_TAG" == "true" ]; then
    local git_last_stable_tag="$(get_git_last_stable_tag)"
    if [ -n "$git_last_stable_tag" ]; then
      export CI_COMMIT_REF_PROTECTED="true"
      export GIT_RESET_TAG="$git_last_stable_tag"
      git_reset_from_tag
      # NOTE: Setting $CI_COMMIT_TAG before calling 'git_reset_from_tag' will skip the git reset stuff
      #       So you must keep the line below after the 'git_reset_from_tag' call
      export CI_COMMIT_TAG="$git_last_stable_tag"
    else
      echo WARNING: Last stable git tag not found
    fi
  fi
}

# Remove tag names that are matching the regex (Git SHA1), keep always at least 3 and remove those who are older than 8 days
# See: https://docs.gitlab.com/14.5/ee/api/container_registry.html#delete-registry-repository-tags-in-bulk
function cleanup_registry() {
  local registry_id="$1"
  if [ -z "$registry_id" ]; then
    echo "ERROR: No registry id given!"
    exit 1
  fi
  if [ -z "$GITLAB_API_TOKEN" ]; then
    echo ERROR: \$GITLAB_API_TOKEN variable is missing
    exit 1
  fi

  curl --silent --show-error --fail-with-body --request DELETE --data-urlencode 'name_regex_delete=(.+-)?[0-9a-f]{40}' --data 'keep_n=3' --data 'older_than=8d' --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$CI_API_V4_URL/projects/$CI_PROJECT_ID/registry/repositories/$registry_id/tags"
  echo "" # add a new line
}

# Can be execute only one time per hour
function cleanup_registries() {
  # wget from alpine:3.10 or docker:stable is buggy with SSL and proxy.
  # So we install curl instead, if it isn't already installed
  local curl_is_installed=$(which curl || true)
  if [ -z "$curl_is_installed" ]; then
    apk add --no-cache curl
  fi

  local jq_is_installed=$(which jq || true)
  if [ -z "$jq_is_installed" ]; then
    apk add --no-cache jq
  fi

  if [ -z "$GITLAB_API_TOKEN" ]; then
    echo ERROR: \$GITLAB_API_TOKEN variable is missing
    exit 1
  fi

  local result=$(curl --silent --show-error --fail --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$CI_API_V4_URL/projects/$CI_PROJECT_ID/registry/repositories?per_page=100")
  local ci_registry_ids=$(echo "$result" | jq -r '.[] .id')
  for ci_registry_id in $ci_registry_ids; do
    echo "INFO: Cleaning registry id '$ci_registry_id' for the project id '$CI_PROJECT_ID'..."
    cleanup_registry $ci_registry_id
  done
}
