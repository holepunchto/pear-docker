FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV PATH=/root/.local/bin:$PATH

# Pear needs libatomic1; sodium-native needs libstdc++6.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libatomic1 \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Bump PEAR_CACHEBUST (e.g. --build-arg PEAR_CACHEBUST=$(date +%s)) to
# reinstall Pear without rebuilding the system packages above.
ARG PEAR_CACHEBUST=1

# Do not run Pear during the build. Its sidecar state is tied to the build
# filesystem.
RUN curl -fsSL https://install.pears.com/pear.sh | sh

WORKDIR /workspace

CMD ["bash"]
