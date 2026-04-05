# userbox

Pre-built OCI container image for user environment tools, consumed by
[distrobox](https://distrobox.it/) on
[Tilefin-DX](https://github.com/repentsinner/tiled-bluefin-dx-nvidia-open).

Separates personal tools from the immutable system image. Edit the
Containerfile, push, and the next login picks up the change.

## What's in the box

### CLI tools

| Tool | Source | Purpose |
|---|---|---|
| `bat` | Fedora RPM | Cat with syntax highlighting |
| `gh` | Fedora RPM | GitHub CLI |
| `chezmoi` | Fedora RPM | Dotfile manager |
| `direnv` | Fedora RPM | Per-directory env vars |
| `zoxide` | Fedora RPM | Smart cd |
| `starship` | COPR `atim/starship` | Shell prompt |
| `eza` | GitHub release | Modern ls |
| `bws` | GitHub release | Bitwarden Secrets CLI |
| `fvm` | fvm.app installer | Flutter Version Manager |

### Flutter Linux build toolchain

| Package | Purpose |
|---|---|
| `clang` | C++ compiler |
| `cmake` | Build system |
| `ninja-build` | Build tool |
| `gtk3-devel` | GTK3 headers |
| `mesa-libGL-devel` | OpenGL headers |
| `mesa-libEGL-devel` | EGL headers |
| `egl-utils` | `eglinfo` diagnostic |
| `systemd-devel` | libudev headers |

`fvm` manages the Flutter SDK at runtime. These are the system
libraries and compilers Flutter links against when building for
Linux desktop.

## What's NOT in the box

Tools with native installers and built-in update commands manage
themselves in `~/.local/bin`. Userbox would replace a working
self-update path with a CI rebuild cycle.

| Tool | Install | Update |
|---|---|---|
| `uv` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` | `uv self update` |
| `mise` | `curl https://mise.run \| sh` | `mise self-update` |
| `claude` | `npm install -g @anthropic-ai/claude-code` | `claude update` |

## Host-side integration

The image alone does nothing — distrobox needs a `.ini` file to
create the container and export its binaries. That file lives at
`~/.config/distrobox/userbox.ini` and is managed by
[chezmoi](https://github.com/repentsinner/dotfiles). It declares
the image, exported bins, and container lifecycle options
(`replace=true`, `pull=true`).

When adding a tool to the Containerfile, also add its path to
`exported_bins` in the `.ini` — otherwise the binary won't appear
in `~/.local/bin` after container recreation.

## Adding tools

Edit `Containerfile`, push to `main`. CI builds and publishes to
`ghcr.io/repentsinner/userbox:latest`. Both CLI and GUI tools work —
distrobox forwards Wayland and GPU access.

## Updating pinned versions

`eza` and `bws` are version-pinned as `ARG`s at the top of the
Containerfile. The weekly CI schedule rebuilds against the latest
`fedora-toolbox:42` base for security updates, but pinned tools need
a manual version bump.
