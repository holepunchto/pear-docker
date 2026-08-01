# pear-cli docker image

A Docker/Podman image for running [Pear](https://docs.pears.com/) (Holepunch)
inside Ubuntu 24.04.

The image installs Node.js 24 via nvm, installs `pear` globally via npm, and
runs `pear -v` once at build time so Pear's one-time P2P bootstrap
(`Bootstrapping: pear://...`) is baked into the image layer. Containers
started from the built image get a working `pear` command immediately, with
no bootstrap delay and no "restart your terminal" step needed.

Also included in the image is pear-install, so you can install an app inside a container. 
A nice way to test out pear apps quickly with less risk.

## Build

With Podman (or Docker, swap the binary):

```sh
podman-compose build
```

or directly:

```sh
podman build -t pear-sandbox .
```

## Run

Drop into a shell with `pear` ready to go:

```sh
podman-compose run --rm pear bash
```

Run a one-off pear command:

```sh
podman-compose run --rm pear pear -v
```

The `./workspace` directory on the host is mounted at `/workspace` inside the
container (also the container's working directory), so any Pear project you
create or `pear stage`/`pear seed` from there persists on the host across
container runs.

## Updating Pear

Pear ships new versions fairly often. Because the image layers are cached,
a plain `podman-compose build` / `podman build` will keep reusing the old
`npm i -g pear` layer forever, even after Pear releases a new version.

To force `pear` (and the `pear -v` bootstrap and `pear-install`) to reinstall
without rebuilding the earlier apt/nvm/Node layers, pass a new value for the
`PEAR_CACHEBUST` build arg — any value that differs from the last build works,
e.g. the current timestamp:

With podman-compose:

```sh
PEAR_CACHEBUST=$(date +%s) podman-compose build
```

Or directly with podman/docker:

```sh
podman build --build-arg PEAR_CACHEBUST=$(date +%s) -t pear:latest .
```

You should see `STEP .../... RUN npm i -g pear` (and the following steps)
run fresh instead of printing `--> Using cache`. Then re-tag/push as usual
(see below).

## Publishing to Docker Hub

Publishing is automated via the `.github/workflows/docker-publish.yml` GitHub
Actions workflow, which authenticates to Docker Hub using [OIDC](https://www.docker.com/blog/docker-oidc-connections-for-github-actions-available-for-docker-orgs/)
(no long-lived Docker Hub password/token stored in GitHub).

- Push to `main` publishes `docker.io/tetherto/pear:latest` and `:edge`.
- Pushing a version tag (e.g. `v1.2.3`) publishes semver tags `1.2.3`, `1.2`,
  and `1`.
- The workflow can also be run manually from the Actions tab.

Every build passes a fresh `PEAR_CACHEBUST` value so published images always
bootstrap the current release of Pear rather than reusing a cached layer.

### One-time setup

1. In [Docker Home](https://app.docker.com/), create an OIDC connection for
   the `tetherto` org (Settings → OIDC connections) scoped to this repo, e.g.
   subject `repo:holepunchto/pear-docker:*`.
2. Add the connection ID as a repository secret named
   `DOCKERHUB_OIDC_CONNECTIONID` (Settings → Secrets and variables → Actions).

No Docker Hub password or access token is needed once this is configured.

To publish manually instead:

```sh
podman build -t docker.io/tetherto/pear:latest .
podman push docker.io/tetherto/pear:latest
```

## Notes

- `libatomic1` is required on Ubuntu 24.04 for Pear's bootstrapped runtime —
  without it, the first `pear -v` fails with "Installation failed. The
  required library libatomic.so was not found on the system."
- Pear's bootstrap writes to `/root/.config/pear` and `/root/.local/bin/pear`
  inside the image; these are baked in as part of the build, not created at
  container start.
