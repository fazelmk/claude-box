# Immutable image for running Claude Code inside a read-only Podman container.
FROM registry.fedoraproject.org/fedora:44

# Runtime deps Claude Code shells out to (git, ripgrep, a pager) plus what the
# installer needs (curl, tar, gzip, ca-certificates).
RUN dnf -y install --setopt=install_weak_deps=False \
        git ripgrep less which findutils \
        curl tar gzip ca-certificates \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Rootless: never run as root inside the container. Create an unprivileged user;
# at runtime --userns=keep-id remaps this to the invoking host user.
RUN useradd --create-home --home-dir /home/claude --uid 1000 --shell /bin/bash claude
USER claude
WORKDIR /home/claude

RUN mkdir -p /home/claude/.local/bin/

# Don't auto-check/download updates; the image is the version of record.
ENV DISABLE_AUTOUPDATER=1 \
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
    HOME=/home/claude \
    PATH=$HOME/.local/bin:$PATH

# Install the Claude Code native binary and relocate it to a system path so the
# root filesystem can be mounted read-only at runtime.
RUN curl -fsSL https://claude.ai/install.sh  | bash

ENTRYPOINT ["/home/claude/.local/bin/claude"]
