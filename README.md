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

## Publishing to Docker Hub

Once the image is verified, tag and push it:

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
