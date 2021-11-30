# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Docker images are now multi-architecture (`linux/amd64` and `linux/arm64` 🦾)
- [macOS](https://apple.com/macos) support
- [Windows](https://microsoft.com/windows) support, but it could be unstable ⚠️
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer <abbr title="Community Edition">CE</abbr> [2.9.3](https://app.swaggerhub.com/apis/portainer/portainer-ce/2.9.2) API

### Changed
- Upgrade Operating System of Docker based images, with [Alpine 3.15](https://hub.docker.com/_/alpine)
- Use Docker [Compose 2.1.1](https://github.com/docker/compose/releases/tag/v2.1.1) instead of Docker [Compose 1.x](https://github.com/docker/compose/releases/tag/1.28.0)
- Reduce Docker images size, based on Alpine and Debian, again

### Fixed
- Fix documentation scrolling between pages, with the [`auto2top`](https://docsify.js.org/#/configuration?id=auto2top) option of [docsify](https://docsify.js.org)

### Removed
- Remove parallel requests improvement, because it's buggy in some situations...
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer [2.1.1](https://app.swaggerhub.com/apis/deviantony/Portainer/2.0.1) API

## [1.3.0-alpha] - 2021-09-14
### Changed
- **Breaking Change**: [HTTPie](https://httpie.io/) is replaced by [cURL](https://curl.se), for smaller Docker images, faster execution and to be more portable
- Boost performance for some actions like `status`, `tasks` and `tasks:healthy`, with parallel requests

### Fixed
- Running concurrently `psu` commands should work now, by creating unique temporary file names
- Fix `psu tasks:healthy` action output, when an error occurs

## [1.2.0] - 2021-09-14
### Added
- Add tests for `actions`, `containers` and `services` actions
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer [1.24.2](https://app.swaggerhub.com/apis/deviantony/Portainer/1.24.1) API

### Changed
- Downgrade Docker Compose from [1.29.2](https://github.com/docker/compose/releases/tag/1.29.2) to [1.28.0](https://github.com/docker/compose/releases/tag/1.28.0) for Alpine image, to get faster builds 🚀
- Reduce Docker images size based on Alpine, again
- Better documentation

### Fixed
- Tests should run fine now with macOS

### Removed
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer [1.24.1](https://app.swaggerhub.com/apis/deviantony/Portainer/1.24.1) API
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer [2.0.1](https://app.swaggerhub.com/apis/deviantony/Portainer/2.0.1) API

## [1.2.0-beta.1] - 2021-09-03
### Added
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer <abbr title="Community Edition">CE</abbr> [2.5.1](https://app.swaggerhub.com/apis/portainer/portainer-ce/2.5.1) API
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer <abbr title="Community Edition">CE</abbr> [2.6.3](https://app.swaggerhub.com/apis/portainer/portainer-ce/2.6.3) API

### Changed
- Use Docker [Compose 1.29.2](https://github.com/docker/compose/releases/tag/1.29.2) instead of Docker [Compose 1.28.3](https://github.com/docker/compose/releases/tag/1.28.3)
- Upgrade Operating System of Docker based images, with [Alpine 3.14](https://hub.docker.com/_/alpine) and [Debian 11](https://hub.docker.com/_/debian)
- Reduce Docker images size
- Use [Traefik 2.5](https://doc.traefik.io/traefik/v2.5) instead of [Traefik 2.4](https://doc.traefik.io/traefik/v2.4) for testing

### Fixed
- Fix [`rm`](docs/README.md#rm) <small>(remove)</small> action with Portainer <abbr title="Community Edition">CE</abbr> 2.6

## [1.2.0-alpha] - 2021-02-19
### Added
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer <abbr title="Community Edition">CE</abbr> [2.0.1](https://app.swaggerhub.com/apis/deviantony/Portainer/2.0.1) API
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer <abbr title="Community Edition">CE</abbr> [2.1.1](https://app.swaggerhub.com/apis/deviantony/Portainer/2.0.1) API

### Changed
- Use Docker [Compose 1.28.3](https://github.com/docker/compose/releases/tag/1.28.3) instead of Docker [Compose 1.26.2](https://github.com/docker/compose/releases/tag/1.26.2)
- Use [Traefik 2.4](https://doc.traefik.io/traefik/v2.4) instead of [Traefik 2.2](https://doc.traefik.io/traefik/v2.2) for testing
- Upgrade Operating System of Docker based images, with [Alpine 3.13](https://hub.docker.com/_/alpine)

### Removed
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer [1.22.2](https://app.swaggerhub.com/apis/deviantony/Portainer/1.22.2) API
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer [1.23.2](https://app.swaggerhub.com/apis/deviantony/Portainer/1.23.2) API

## [1.1.0] - 2021-02-18
### Changed
- Use [Traefik 2.2](https://doc.traefik.io/traefik/v2.2) instead of [Traefik 2.1](https://doc.traefik.io/traefik/v2.1) for testing

### Fixed
- Changelog link for `psu` version `1.1.0-alpha`
- Fix `cryptography` building error

## [1.1.0-alpha] - 2020-07-29
### Changed
- Upgrade Operating System of Docker based images, with [Alpine 3.12](https://hub.docker.com/_/alpine) and [Debian 10](https://hub.docker.com/_/debian)

### Fixed
- Docker build should fail if a shell command failed

## [1.0.7] - 2021-02-16
### Fixed
- Remove useless packages after building `docker-compose`, for the main Docker image

## [1.0.6] - 2021-02-16
### Fixed
- Docker build should fail if a shell command failed
- Fix `cryptography` building error

## [1.0.5] - 2020-07-29
### Added
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer [1.24.1](https://app.swaggerhub.com/apis/deviantony/Portainer/1.24.1) API

### Removed
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer [1.21.0](https://app.swaggerhub.com/apis/deviantony/Portainer/1.21.0) API

## [1.0.4] - 2020-01-27
### Added
- Use the `$CLEANUP_REGISTRIES_ENABLED` CI variable for deleting Docker repository tags in bulk

### Changed
- Remove unused git and Docker tags in `README.md`

### Fixed
- Fix scheduled pipeline who update Docker images for the latest stable git tag

## [1.0.3] - 2020-01-09
### Added
- Cleaning old Docker repository builds tags via [GitLab API](https://docs.gitlab.com/12.6/ee/api/container_registry.html#delete-repository-tags-in-bulk)

### Changed
- Use [Traefik 2.1](https://doc.traefik.io/traefik/v2.1) instead of [Traefik 1.7](https://doc.traefik.io/traefik/v1.7) for testing

### Fixed
- Build script for the latest stable git tag of a given git branch

## [1.0.2] - 2019-12-10
### Added
- Test <abbr title="Portainer Stack Utils">PSU</abbr> with Portainer [1.23.0](https://app.swaggerhub.com/apis/deviantony/Portainer/1.23.0) API

## [1.0.1] - 2019-10-29
### Fixed
- If the `--insecure` option is set to `false` and the `HTTPIE_VERIFY_SSL` environment variable is set, we keep its value instead of overwrite it to `yes`.
  Useful when we want to use Custom <abbr title="Certificate Authority">CA</abbr> (e.g. `HTTPIE_VERIFY_SSL=/etc/ssl/certs/ca-certificates.crt`). For more information, you can read the [HTTPie docs](https://httpie.org/doc/1.0.3#custom-ca-bundle)

## [1.0.0] - 2019-07-25
### Added
- New actions: `ls`, `status`, `services`, `tasks`, `tasks:healthy`, `containers`, `login`, `lint`, `inspect`, `system:info`, `actions`, `help` and `version`
- New options: `--auth-token=[AUTH_TOKEN]`,	`--compose-file-base64=[BASE64]`, `--env-file-base64=[BASE64]`, `--timeout=[SECONDS]`, `--detect-job=[true|false]`, `--service=[SERVICE_NAME]`, `--insecure`, `--masked-variables`, `--quiet`, `--lint`, `--help` and `--version`
- New flags: `-A`, `-C`, `-F`, `-G`, `-T`, `-j`, `-i`, `-S`, `-m`, `-q`, `-L`, `-h` and `-V`
- New environment variables: `PORTAINER_AUTH_TOKEN`, `TIMEOUT`, `AUTO_DETECT_JOB`, `PORTAINER_SERVICE_NAME`, `MASKED_VARIABLES`, `QUIET_MODE` and `DOCKER_COMPOSE_LINT`
- The Docker image include now `docker-compose` to be able to lint Docker compose/stack file
- The `core` Docker image variant doesn't include `docker-compose`, so it's a bit smaller. But you can't lint Docker compose/stack file before deploying a stack
- The `debian` and `debian-core` Docker image variants, use [Debian](https://www.debian.org) instead of [Alpine](https://alpinelinux.org/) as base image for `psu`
- Online documentation via [docsify](https://docsify.js.org)
- Tests who run automatically on each git push via [GitLab CI](https://docs.gitlab.com/ce/ci/)

### Changed
- The `undeploy` action is now an aliased action. You should use `rm` action instead

### Deprecated
- The `--secure=[yes|no]` option and `-s` flag are deprecated. Use the `--insecure` option instead (`psu <action> ... --insecure`)
- The `--action=[ACTION_NAME]` option and `-a` flag are deprecated. Use `<action>` argument instead (`psu <action> ...`)

## [0.1.2] - 2019-10-29
### Changed
- Delegated compose file loading and escaping to jq [#33](https://gitlab.com/psuapp/psu/merge_requests/33)

## [0.1.1] - 2019-06-05
### Fixed
- Fixed error when environment variables loaded from file contain spaces in their values [#14](https://gitlab.com/psuapp/psu/merge_requests/14)

## [0.1.0] - 2019-05-24
### Added
- Stack deployment
- Stack update
- Stack undeployment
- Configuration through environment variables
- Configuration through flags
- Stack environment variables loading from file
- Optional SSL verification of Portainer instance
- Verbose mode
- Debug mode
- Strict mode

[Unreleased]: https://gitlab.com/psuapp/psu/compare/v1.3.0-alpha...1-3-next
[1.3.0-alpha]: https://gitlab.com/psuapp/psu/-/tags/v1.3.0-alpha
[1.2.0]: https://gitlab.com/psuapp/psu/-/tags/v1.2.0
[1.2.0-beta.1]: https://gitlab.com/psuapp/psu/-/tags/v1.2.0-beta.1
[1.2.0-alpha]: https://gitlab.com/psuapp/psu/-/tags/v1.2.0-alpha
[1.1.0]: https://gitlab.com/psuapp/psu/-/tags/v1.1.0
[1.1.0-alpha]: https://gitlab.com/psuapp/psu/-/tags/v1.1.0-alpha
[1.0.7]: https://gitlab.com/psuapp/psu/-/tags/v1.0.7
[1.0.6]: https://gitlab.com/psuapp/psu/-/tags/v1.0.6
[1.0.5]: https://gitlab.com/psuapp/psu/-/tags/v1.0.5
[1.0.4]: https://gitlab.com/psuapp/psu/-/tags/v1.0.4
[1.0.3]: https://gitlab.com/psuapp/psu/-/tags/v1.0.3
[1.0.2]: https://gitlab.com/psuapp/psu/-/tags/v1.0.2
[1.0.1]: https://gitlab.com/psuapp/psu/-/tags/v1.0.1
[1.0.0]: https://gitlab.com/psuapp/psu/-/tags/v1.0.0
[0.1.2]: https://gitlab.com/psuapp/psu/-/tags/v0.1.2
[0.1.1]: https://gitlab.com/psuapp/psu/-/tags/v0.1.1
[0.1.0]: https://gitlab.com/psuapp/psu/-/tags/v0.1.0
