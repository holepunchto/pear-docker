# pear-cli docker image

A Docker/Podman image for running [Pear](https://docs.pears.com/) (Holepunch).

The image uses Debian Bookworm Slim and installs Pear from
`https://install.pears.com/pear.sh`. The `pear` command is ready when the
container starts.

Use `pear install` to install apps inside the container—a quick way to try Pear
apps with less risk.

## Build

With Podman (or Docker, swap the binary):

```sh
podman-compose build
```

or directly:

```sh
podman build -t pear .
```

## Run

Drop into a shell with `pear` ready to go:

```sh
podman-compose run -v $HOME/pear-mount:/root/.config/pear --rm pear bash
```

Run a one-off Pear command:

```sh
podman-compose run -v $HOME/pear-mount:/root/.config/pear --rm pear pear -v
```

The host's `./workspace` directory is mounted at `/workspace`, the container's
default working directory. Pear projects created, staged, or seeded there stay
on the host between runs.

## Updating Pear

Docker may reuse an older Pear installation after a new version ships. To
reinstall Pear without rerunning `apt`, give `PEAR_CACHEBUST` a new value, such
as the current timestamp:

With podman-compose:

```sh
PEAR_CACHEBUST=$(date +%s) podman-compose build
```

Or directly with podman/docker:

```sh
podman build --build-arg PEAR_CACHEBUST=$(date +%s) -t pear:latest .
```

This reruns the `RUN curl ...` step. Then re-tag and push as usual (see below).

## Publishing to Docker Hub

`.github/workflows/docker-publish.yml` publishes images to Docker Hub and uses
[OIDC](https://www.docker.com/blog/docker-oidc-connections-for-github-actions-available-for-docker-orgs/)
for authentication. No Docker Hub password or access token is stored in
GitHub.

- Push to `main` publishes `docker.io/tetherto/pear:latest` and `:edge`.
- Pushing a version tag (e.g. `v1.2.3`) publishes semver tags `1.2.3`, `1.2`,
  and `1`.
- The workflow can also be run manually from the Actions tab.

Every build passes a fresh `PEAR_CACHEBUST` value so published images always
install the current release of Pear rather than reusing a cached layer.

### One-time setup

1. In [Docker Home](https://app.docker.com/), create an OIDC connection for
   the `tetherto` org (Settings → OIDC connections) scoped to this repo, e.g.
   subject `repo:holepunchto/pear-docker:*`.
2. Add the connection ID as a repository secret named
   `DOCKERHUB_OIDC_CONNECTIONID` (Settings → Secrets and variables → Actions).

To publish manually instead:

```sh
podman build -t docker.io/tetherto/pear:latest .
podman push docker.io/tetherto/pear:latest
```

## Notes

- `libatomic1` is required by Pear. Without it, `pear -v` fails with:
  "Installation failed. The required library libatomic.so was not found on
  the system."
- Pear stores its runtime state in `/root/.config/pear`. Mount that directory
  to keep the state between containers.
- The installer verifies the Pear download, but the install script itself is
  fetched unpinned over HTTPS.
- The image includes Debian's standard command-line tools and curl, but not
  Node.js or npm.
