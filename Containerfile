FROM registry.fedoraproject.org/fedora-toolbox:42

# Versions pinned for reproducibility — update and push to rebuild.
ARG EZA_VERSION=0.23.4
ARG BWS_VERSION=1.0.0

# --- RPM packages (default repos) ---
RUN dnf5 install -y \
        gh \
        chezmoi \
        direnv \
        bat \
        zoxide \
    && dnf5 clean all

# --- Flutter Linux build toolchain (default repos) ---
RUN dnf5 install -y \
        clang \
        libcxx-devel \
        libcxx-static \
        libcxxabi-static \
        cmake \
        ninja-build \
        gtk3-devel \
        mesa-libGL-devel \
        mesa-libEGL-devel \
        mesa-libgbm-devel \
        egl-utils \
        systemd-devel \
    && dnf5 clean all

# --- starship (COPR — not in default Fedora 42 repos) ---
RUN dnf5 -y copr enable atim/starship \
    && dnf5 install -y starship \
    && dnf5 clean all

# --- eza (orphaned in Fedora 42 — GitHub release) ---
RUN curl -Lo /tmp/eza.tar.gz \
        "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" \
    && tar -xzf /tmp/eza.tar.gz -C /tmp \
    && install -Dm755 /tmp/eza /usr/bin/eza \
    && rm -f /tmp/eza.tar.gz /tmp/eza

# --- bws (Bitwarden Secrets CLI — GitHub release) ---
RUN curl -Lo /tmp/bws.zip \
        "https://github.com/bitwarden/sdk/releases/download/bws-v${BWS_VERSION}/bws-x86_64-unknown-linux-gnu-${BWS_VERSION}.zip" \
    && unzip /tmp/bws.zip -d /tmp \
    && install -Dm755 /tmp/bws /usr/bin/bws \
    && rm -f /tmp/bws.zip /tmp/bws

# --- fvm (Flutter Version Manager — no self-update command) ---
RUN curl -fsSL https://fvm.app/install.sh | bash \
    && install -Dm755 /root/fvm/bin/fvm /usr/bin/fvm \
    && rm -rf /root/fvm
