FROM registry.fedoraproject.org/fedora-toolbox:42

# --- RPM packages (default repos) ---
RUN dnf5 install -y \
        gh \
        chezmoi \
        fish \
        rbw \
        pinentry \
        edid-decode \
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

# --- fvm (Flutter Version Manager — no self-update command) ---
RUN curl -fsSL https://fvm.app/install.sh | bash \
    && install -Dm755 /root/fvm/bin/fvm /usr/bin/fvm \
    && rm -rf /root/fvm
