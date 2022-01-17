<h1>Portainer Stack Utils</h1>
<div class="docsify-hidden">

[![Docker Pulls](https://img.shields.io/docker/pulls/psuapp/psu.svg)](https://hub.docker.com/r/psuapp/psu/)
[![pipeline status](https://gitlab.com/psuapp/psu/badges/1-3-stable/pipeline.svg)](https://gitlab.com/psuapp/psu/commits/1-3-stable)

Bash script to deploy/update/remove stacks in a [Portainer](https://portainer.io/) instance from a [docker-compose](https://docs.docker.com/compose) [yaml file](https://docs.docker.com/compose/compose-file).

_Based on previous work by [@vladbabii](https://github.com/vladbabii) on [docker-how-to/portainer-bash-scripts](https://github.com/docker-how-to/portainer-bash-scripts)._

<h2>Table of contents</h2>
<!-- Generated by https://github.com/mcpride/atom-mdtoc -->
<!-- MDTOC maxdepth:2 firsth1:2 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [How to install](#how-to-install)   
   - [Standalone](#standalone)   
   - [Docker image, variants and multi-architecture](#docker-image-variants-and-multi-architecture)   
- [How to use](#how-to-use)   
   - [With options](#with-options)   
   - [With flags](#with-flags)   
   - [With envvars](#with-envvars)   
- [Documentation](#documentation)   
- [Supported Portainer API](#supported-portainer-api)   
- [License](#license)   

<!-- /MDTOC -->
</div>

## How to install

### Standalone

> **Note**: The easiest way to install `psu` is to use [Docker method](#docker-image-variants-and-multi-architecture), instead of this one

Check the [Requirements](#requirements) section then [git] clone the repo and use the [bash] script below:

```bash
git clone https://gitlab.com/psuapp/psu.git
cd psu/
# Allow the 'psu' command to run everywhere:
export PATH="$(pwd):$PATH"
# Or if you want it permanent, with a super user account, run:
# ln -s $(pwd)/psu /usr/local/bin
#
# Then you can use psu, e.g.
psu deploy ...
```

For detailed instructions, see [How to use](#how-to-use) section.

#### Requirements

You will need these dependencies installed:

##### [Linux] based systems <small>([Alpine], [Debian], [Ubuntu]...)</small>
- [bash]<sup title="required">\*</sup> <small>(>= 4.4.23)</small>
- [curl]<sup title="required">\*</sup> <small>(>= 7.64.0, but >= 7.76.0 is recommended)</small>
- [jq]<sup title="required">\*</sup> <small>(>= 1.5.1)</small>
- [uuidgen] recommended only for some <abbr title="Operating System">OS</abbr> <small>(Alpine and Debian work fine without it)</small>

For [Debian] and similar apt-powered [Linux] systems, run: `apt install bash curl jq`

##### [macOS]
- [bash]<sup title="required">\*</sup> <small>(>= 4.4.23)</small>
- [curl]<sup title="required">\*</sup> <small>(>= 7.64.0, but >= 7.76.0 is recommended)</small>
- [jq]<sup title="required">\*</sup> <small>(>= 1.5.1)</small>
- [timeout]<sup title="required">\*</sup> <small>(included in the [coreutils] package)</small>
- greadlink <small>(included in the [coreutils] package)</small>

You should install [Homebrew], then run: `brew install bash coreutils jq`

##### [Windows]
- [bash]<sup title="required">\*</sup> <small>(>= 4.4.23)</small>
- [curl]<sup title="required">\*</sup> <small>(>= 7.64.0, but >= 7.76.0 is recommended)</small>
- [jq]<sup title="required">\*</sup> <small>(>= 1.5.1)</small>

> **Note**: `psu`should work with [Windows], but it could be unstable ⚠️

You should download and install [Git](https://git-scm.com/download/win) and [jq](https://stedolan.github.io/jq/download) for [Windows]

##### For all systems
- [docker-compose] is recommended but not required <small>(useful for linting docker compose/stack files)</small>

<sup>\*</sup> = required

### Docker image, variants and multi-architecture

If you don't want or can't install `psu` and its dependencies, you can run it with the default [published Docker image](https://hub.docker.com/r/psuapp/psu), like this:
```bash
docker run psuapp/psu:1.3 deploy ...
```
> **Note**: Docker images are also available on [GitLab](https://gitlab.com/psuapp/psu/container_registry).

For detailed instructions, see [How to use](#how-to-use) section.

#### Supported tags

Published Docker images are [tagged](https://hub.docker.com/r/psuapp/psu/tags) matching [GitLab tags](https://gitlab.com/psuapp/psu/-/tags):

<!-- - `dev` -> [`dev`](https://gitlab.com/psuapp/psu/-/tags/dev) -->

- `1`, `1.3`, `1.3.1` -> [`v1.3.1`](https://gitlab.com/psuapp/psu/-/tags/v1.3.1)
- `1.3.0-beta.1` -> [`v1.3.0-beta.1`](https://gitlab.com/psuapp/psu/-/tags/v1.3.0-beta.1)
- `1.3.0-alpha` -> [`v1.3.0-alpha`](https://gitlab.com/psuapp/psu/-/tags/v1.3.0-alpha)
- `1.2`, `1.2.0` -> [`v1.2.0`](https://gitlab.com/psuapp/psu/-/tags/v1.2.0)
- `1.2.0-beta.1` -> [`v1.2.0-beta.1`](https://gitlab.com/psuapp/psu/-/tags/v1.2.0-beta.1)
- `1.2.0-alpha` -> [`v1.2.0-alpha`](https://gitlab.com/psuapp/psu/-/tags/v1.2.0-alpha)
- `1.1`, `1.1.0` -> [`v1.1.0`](https://gitlab.com/psuapp/psu/-/tags/v1.1.0)
- `1.1.0-alpha` -> [`v1.1.0-alpha`](https://gitlab.com/psuapp/psu/-/tags/v1.1.0-alpha)
- `1.0`, `1.0.7` -> [`v1.0.7`](https://gitlab.com/psuapp/psu/-/tags/v1.0.7)
- `1.0.6` -> [`v1.0.6`](https://gitlab.com/psuapp/psu/-/tags/v1.0.6)
- `1.0.5` -> [`v1.0.5`](https://gitlab.com/psuapp/psu/-/tags/v1.0.5)
- `1.0.4` -> [`v1.0.4`](https://gitlab.com/psuapp/psu/-/tags/v1.0.4)
- `1.0.3` -> [`v1.0.3`](https://gitlab.com/psuapp/psu/-/tags/v1.0.3)
- `1.0.2` -> [`v1.0.2`](https://gitlab.com/psuapp/psu/-/tags/v1.0.2)
- `1.0.1` -> [`v1.0.1`](https://gitlab.com/psuapp/psu/-/tags/v1.0.1)
- `1.0.0` -> [`v1.0.0`](https://gitlab.com/psuapp/psu/-/tags/v1.0.0)
- `0.1.2` -> [`v0.1.2`](https://gitlab.com/psuapp/psu/-/tags/v0.1.2)
- `0.1.1` -> [`v0.1.1`](https://gitlab.com/psuapp/psu/-/tags/v0.1.1)
- `0.1.0` -> [`v0.1.0`](https://gitlab.com/psuapp/psu/-/tags/v0.1.0)

##### Variants

The `core` variant doesn't include `docker-compose`, so it's a bit smaller.
But you can't lint Docker compose/stack file before deploying a stack.
<!-- - `dev-core` -> [`dev`](https://gitlab.com/psuapp/psu/-/tags/dev) -->

- `1-core`, `1.3-core`, `1.3.1-core` -> [`v1.3.1`](https://gitlab.com/psuapp/psu/-/tags/v1.3.1)
- `1.2-core`, `1.2.0-core` -> [`v1.2.0`](https://gitlab.com/psuapp/psu/-/tags/v1.2.0)
- `1.1-core`, `1.1.0-core` -> [`v1.1.0`](https://gitlab.com/psuapp/psu/-/tags/v1.1.0)
- `1.0-core`, `1.0.7-core` -> [`v1.0.7`](https://gitlab.com/psuapp/psu/-/tags/v1.0.7)

The `debian` and `debian-core` variants use [Debian](https://www.debian.org) instead of [Alpine](https://alpinelinux.org/) as base image for `psu`.
<!-- - `dev-debian` -> [`dev`](https://gitlab.com/psuapp/psu/-/tags/dev)
- `dev-debian-core` -> [`dev`](https://gitlab.com/psuapp/psu/-/tags/dev) -->

- `1-debian`, `1.3-debian`, `1.3.1-debian` -> [`v1.3.1`](https://gitlab.com/psuapp/psu/-/tags/v1.3.1)
- `1-debian-core`, `1.3-debian-core`, `1.3.1-debian-core` -> [`v1.3.1`](https://gitlab.com/psuapp/psu/-/tags/v1.3.1)
- `1.2-debian`, `1.2.0-debian` -> [`v1.2.0`](https://gitlab.com/psuapp/psu/-/tags/v1.2.0)
- `1.2-debian-core`, `1.2.0-debian-core` -> [`v1.2.0`](https://gitlab.com/psuapp/psu/-/tags/v1.2.0)
- `1.1-debian`, `1.1.0-debian` -> [`v1.1.0`](https://gitlab.com/psuapp/psu/-/tags/v1.1.0)
- `1.1-debian-core`, `1.1.0-debian-core` -> [`v1.1.0`](https://gitlab.com/psuapp/psu/-/tags/v1.1.0)
- `1.0-debian`, `1.0.7-debian` -> [`v1.0.7`](https://gitlab.com/psuapp/psu/-/tags/v1.0.7)
- `1.0-debian-core`, `1.0.7-debian-core` -> [`v1.0.7`](https://gitlab.com/psuapp/psu/-/tags/v1.0.7)

##### Multi-Architecture

The Docker images support multi-architecture: `linux/amd64`, `linux/arm64` and `linux/arm/v7`.

On ARM machines, if you get this error when running a `psu` Docker image:
```
standard_init_linux.go:228: exec user process caused: exec format error
```

You need to install `linux/amd64` QEMU binary, like this:
```bash
docker run --privileged --rm tonistiigi/binfmt --install linux/amd64
```
Then run your `psu` Docker image again and it should work 🤞

And if you want to uninstall this QEMU binary, run this command:
```bash
docker run --privileged --rm tonistiigi/binfmt --uninstall linux/amd64
```

#### Testing/debugging:

For testing/debugging, you can use this Docker image in interactive mode, to run any commands inside the container:
```bash
docker run -v $(pwd)/docker-compose.yml:/docker-compose.yml -it --rm --entrypoint bash psuapp/psu:1.3
# Run any commands here! E.g.
$ psu --version
Portainer Stack Utils, version 1.3.1
  License GPLv3: GNU GPL version 3
```

## How to use

The provided `psu` script allows to deploy/update/remove... Portainer stacks. Settings can be passed through envvars and/or options and/or flags. Both envvars, options and flags can be mixed but options or flags will always overwrite envvar values. When deploying a stack, if it doesn't exist a new one is created, otherwise it's updated (unless strict mode is active).

### With options

This is more suitable for standalone script usage.

- `<action>` ("deploy", "rm", "ls"..., required): Whether to deploy, remove, list... the stack, _not an option but an argument_
- `--user` (string, required): Username
- `--password` (string, required): Password
- `--url` (string, required): URL to Portainer
- `--name` (string, required): Stack name
- `--compose-file` (string, required if action=deploy): Path to docker-compose file

For detailed instructions, see the full [options list](docs/README.md#available-options).

#### Examples

```bash
psu deploy --user admin --password password --url https://portainer.local --name mystack --compose-file /path/to/docker-compose.yml --env-file /path/to/env_vars_file
```

```bash
psu rm --user admin --password password --url https://portainer.local --name mystack
```

**With Docker:**
```bash
docker run -v $(pwd)/docker-compose.yml:/docker-compose.yml -v $(pwd)/.env:/.env psuapp/psu:1.3 deploy --user admin --password password --url https://portainer.local --name mystack --compose-file docker-compose.yml --env-file .env
```

### With flags

This is more suitable for standalone script usage.

- `<action>` ("deploy", "rm", "ls"..., required): Whether to deploy, remove, list... the stack, _not a flag but an argument_
- `-u` (string, required): Username
- `-p` (string, required): Password
- `-l` (string, required): URL to Portainer
- `-n` (string, required): Stack name
- `-c` (string, required if action=deploy): Path to docker-compose file

For detailed instructions, see the full [flags list](docs/README.md#available-options).

#### Examples

```bash
psu deploy -u admin -p password -l https://portainer.local -n mystack -c /path/to/docker-compose.yml -g /path/to/env_vars_file
```

```bash
psu rm -u admin -p password -l https://portainer.local -n mystack
```

**With Docker:**
```bash
docker run -v $(pwd)/docker-compose.yml:/docker-compose.yml -v $(pwd)/.env:/.env psuapp/psu:1.3 deploy -u admin -p password -l https://portainer.local -n mystack -c docker-compose.yml -g .env
```

### With envvars

This is particularly useful for [CI](https://en.wikipedia.org/wiki/Continuous_integration)/[CD](https://en.wikipedia.org/wiki/Continuous_deployment) pipelines using Docker containers.

- `ACTION` ("deploy", "rm", "ls"..., required): Whether to deploy, remove, list... the stack
- `PORTAINER_USER` (string, required): Username
- `PORTAINER_PASSWORD` (string, required): Password
- `PORTAINER_URL` (string, required): URL to Portainer
- `PORTAINER_STACK_NAME` (string, required): Stack name
- `DOCKER_COMPOSE_FILE` (string, required if action=deploy): Path to docker-compose file

For detailed instructions, see the full [envvars list](docs/README.md#available-environment-variables).

#### Examples

```bash
export ACTION="deploy"
export PORTAINER_USER="admin"
export PORTAINER_PASSWORD="password"
export PORTAINER_URL="https://portainer.local"
export PORTAINER_STACK_NAME="mystack"
export DOCKER_COMPOSE_FILE="/path/to/docker-compose.yml"
export ENVIRONMENT_VARIABLES_FILE="/path/to/env_vars_file"

psu
```

```bash
export ACTION="rm"
export PORTAINER_USER="admin"
export PORTAINER_PASSWORD="password"
export PORTAINER_URL="https://portainer.local"
export PORTAINER_STACK_NAME="mystack"

psu
```

**With Docker:**
```bash
docker run -v $(pwd)/docker-compose.yml:/docker-compose.yml -v $(pwd)/.env:/.env -e ACTION="deploy" -e PORTAINER_USER="admin" -e PORTAINER_PASSWORD="password" -e PORTAINER_URL="https://portainer.local" -e PORTAINER_STACK_NAME="mystack" -e DOCKER_COMPOSE_FILE="docker-compose.yml" -e ENVIRONMENT_VARIABLES_FILE=".env" psuapp/psu:1.3
```

## Documentation

<div class="docsify-hidden">
For advanced usage, see the full <a href="https://psuapp.gitlab.io/psu/1-3-stable"><abbr title="Portainer Stack Utils">PSU</abbr> documentation</a>.
</div>

For detailed instructions, see the [CLI Commands](docs/README.md) documentation.

## Supported Portainer API

<abbr title="Portainer Stack Utils">PSU</abbr> was created for the latest versions of Portainer API, which at the time of writing are [1.24.2](https://app.swaggerhub.com/apis/deviantony/Portainer/1.24.1), [2.6.3](https://app.swaggerhub.com/apis/portainer/portainer-ce/2.6.3), [2.9.3](https://app.swaggerhub.com/apis/portainer/portainer-ce/2.9.3) and [2.11.0](https://app.swaggerhub.com/apis/portainer/portainer-ce/2.11.0).

## License

Source code contained by this project is licensed under the [GNU General Public License version 3](https://www.gnu.org/licenses/gpl-3.0.en.html).

See [LICENSE](LICENSE) file for reference.

[Linux]: https://kernel.org
[Alpine]: https://alpinelinux.org
[Debian]: https://debian.org
[Ubuntu]: https://ubuntu.com/
[macOS]: https://apple.com/macos
[Homebrew]: https://brew.sh
[coreutils]: https://formulae.brew.sh/formula/coreutils
[Windows]: https://microsoft.com/windows
[bash]: https://www.gnu.org/software/bash
[curl]: https://curl.se
[jq]: https://stedolan.github.io/jq
[timeout]: https://man7.org/linux/man-pages/man1/timeout.1.html
[uuidgen]: https://man7.org/linux/man-pages/man1/uuidgen.1.html
[docker-compose]: https://docs.docker.com/compose/install
[git]: https://git-scm.com/
