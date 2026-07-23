FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=24
ENV PATH=/root/.local/bin:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash

RUN . "$NVM_DIR/nvm.sh" \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && ln -sf "$NVM_DIR/versions/node/$(nvm version $NODE_VERSION)/bin/node" /usr/local/bin/node \
    && ln -sf "$NVM_DIR/versions/node/$(nvm version $NODE_VERSION)/bin/npm" /usr/local/bin/npm \
    && ln -sf "$NVM_DIR/versions/node/$(nvm version $NODE_VERSION)/bin/npx" /usr/local/bin/npx

RUN npm i -g pear \
    && ln -sf "$(dirname "$(readlink -f /usr/local/bin/node)")/pear" /usr/local/bin/pear

# Trigger Pear's one-time bootstrap (downloads the pear:// runtime) at build
# time so it's baked into the image instead of happening on every container.
RUN pear -v

# Add pear-install as well

RUN npm i -g pear-install \
    && ln -sf "$(dirname "$(readlink -f /usr/local/bin/node)")/pear-install" /usr/local/bin/pear-install


CMD ["bash"]
