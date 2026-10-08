FROM nixpkgs/nix:nixos-23.11

ARG FIRMWARE_REV=ce69e85f585c724142aae37ddf8a7e019ff19e93
ENV FIRMWARE_REV=${FIRMWARE_REV}

ENV PATH=/root/.nix-profile/bin:/usr/bin:/bin

RUN <<EOF
    set -euo pipefail
    nix-env -iA cachix -f https://cachix.org/api/v1/install
    cachix use moergo-glove80-zmk-dev
    mkdir /config
    # Mirror ZMK repository to make it easier to reference both branches and
    # tags without remote namespacing
    git clone --mirror https://github.com/moergo-sc/zmk /zmk
    GIT_DIR=/zmk git worktree add --detach /src "$FIRMWARE_REV"
EOF

# Cache dependencies for the pinned MoErgo v26.09 firmware.
RUN <<EOF
    cd /src
    nix-shell --run true -A zmk ./default.nix
EOF

COPY --chmod=755 <<EOF /bin/entrypoint.sh
#!/usr/bin/env bash
    set -euo pipefail
    : "\${BRANCH:=\$FIRMWARE_REV}"

    echo "Checking out \$BRANCH from moergo-sc/zmk" >&2
    cd /src
    git fetch origin
    git checkout -q --detach "\$BRANCH"

    echo 'Building Glove80 firmware' >&2
    cd /config
    nix-build ./config --arg firmware 'import /src/default.nix {}' -j2 -o /tmp/combined --show-trace
    install -o "\$UID" -g "\$GID" /tmp/combined/glove80.uf2 ./glove80.uf2
    mkdir -p build/left build/right
    install -m 644 -o "\$UID" -g "\$GID" /tmp/combined/left/* build/left/
    install -m 644 -o "\$UID" -g "\$GID" /tmp/combined/right/* build/right/
EOF

ENTRYPOINT ["/bin/entrypoint.sh"]

# Run build.sh to use this file
