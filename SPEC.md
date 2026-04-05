# SPEC: Userbox — User Environment Distrobox

## Problem

Tilefin-DX bakes user environment tools into the immutable system image.
These tools have no session-startup dependencies — they run on demand.
Including them in the image means:

- Image rebuilds for tool updates or additions.
- Image bloat unrelated to desktop infrastructure.
- No separation between "OS" and "personal user environment."

Affected packages: `gh`, `chezmoi`, `direnv`, `zoxide`, `starship`,
`eza`, `bws`.

## Design

### Separation of concerns

The system image provides desktop infrastructure: compositor, session
services, display manager, theming, fonts, Wayland utilities. Everything
required before or during login.

User environment tools — CLI utilities, dev tools, and GUI applications
that don't belong in the base image — move to a pre-built OCI container
image consumed by distrobox. Distrobox forwards Wayland, GPU drivers
(via `nvidia=true`), and display access, so both CLI and GUI tools work
transparently. CLI tools export via `distrobox-export --bin`; GUI apps
export via `distrobox-export --app`.

Same pattern as Tilefin-DX itself: a Containerfile defines the
environment, CI builds and pushes it to GHCR, and the host pulls and
runs it declaratively.

### Relationship to other repos

This repo produces the OCI image. Two other repos consume it:

- **tiled-bluefin-dx-nvidia-open**: OS image repo. Removes these
  packages from the system image and provides a `ujust setup-userbox`
  recipe as a manual trigger.
- **chezmoi dotfiles**: Owns the distrobox `.ini` (points at the GHCR
  image) and the systemd user unit that assembles the container on
  login.

### Why a pre-built image, not `additional_packages`

`distrobox assemble create --replace` with `additional_packages` runs
`dnf install` on every recreation — 30-60+ seconds. With a pre-built
image, recreation is container startup + exports only — under 15 seconds
with a cached image. This makes ephemeral, recreate-on-login containers
practical.

### Container lifecycle

A systemd user unit runs `distrobox assemble create --replace` on login.
The container is ephemeral: destroyed and recreated from the declaration
each session. No drift from the definition.

The `.ini` sets `replace=true` and `pull=true`. On login:

1. Podman checks GHCR for a new image digest. Downloads only if changed.
2. The existing container is destroyed.
3. A new container is created from the (cached or updated) image.
4. `exported_bins` creates wrapper scripts in `~/.local/bin`.

Between image updates, recreation uses the local cache. Cost: ~10 seconds
on login.

### Architecture

```
userbox repo (this repo)
  ├── Containerfile               ← defines user environment image
  └── .github/workflows/build.yml ← CI: build + push to GHCR
        │
        ▼
  ghcr.io/repentsinner/userbox:latest
        │
        ▼ consumed by
  distrobox assemble create (host)
        │
        ▼
  ~/.local/bin/{gh,eza,starship,fvm,cmake,...}  ← distrobox-export wrappers
```

## Requirements

### R1: Pre-built userbox container image

*Status: not started*

A new repo shall contain a Containerfile based on
`registry.fedoraproject.org/fedora-toolbox:42` that installs:

- RPM packages (default repos): `gh`, `chezmoi`, `direnv`, `zoxide`.
- RPM packages (default repos — Flutter Linux build dependencies):
  `clang`, `cmake`, `ninja-build`, `gtk3-devel`, `mesa-libGL-devel`,
  `mesa-libEGL-devel`, `mesa-utils`, `systemd-devel`, `pkg-config`.
- RPM packages (COPR `atim/starship`): `starship`.
- Direct binary installs: `eza` (GitHub release tarball — orphaned in
  Fedora 42 repos), `bws` (Bitwarden Secrets CLI from
  `bitwarden/sdk` GitHub releases), `fvm` (Flutter Version Manager
  from `fvm.app` install script — no self-update command).

Flutter's Linux desktop target (`flutter build linux`) links against
GTK3, Mesa, and libudev at compile time, and requires clang, cmake,
and ninja as its build toolchain. `fvm` manages the Flutter SDK
itself; these are the system libraries and compilers it depends on.
They are installed in a separate Containerfile layer from the CLI
user tools to keep layer caching independent — a new CLI tool
addition does not invalidate the build-deps layer and vice versa.

The Containerfile shall follow the fedora-toolbox contract (preserve
distrobox compatibility — don't remove `sudo`, don't change the
entrypoint).

Adding tools — CLI or GUI — means editing the Containerfile and
pushing. CI rebuilds the image, and the next login picks it up.

### R2: CI build and publish

*Status: not started*

GitHub Actions shall build and push the image to
`ghcr.io/repentsinner/userbox:latest` on push to `main` and on a weekly
schedule (to pick up base image security updates).

## Out of scope

- **Self-managing tools**: Tools with native installers and built-in
  update commands (e.g., `uv self update`, `claude update`) install
  directly to `~/.local/bin` and maintain themselves. Userbox adds no
  value here — it would replace a working self-update path with a CI
  rebuild cycle.
- **DaVinci Resolve**: Proprietary installer (manual download, EULA
  acceptance) cannot be automated in CI. Architecturally compatible
  with userbox (GPU and Wayland forwarding work), but packaging
  requires a different approach.
- **Flutter SDK**: Managed by `fvm` at runtime, not baked into the
  image.
- **Host-side integration**: Shell aliases, direnv hooks, ujust recipes,
  distrobox `.ini`, and systemd units belong to their respective repos
  (tiled-bluefin-dx-nvidia-open, chezmoi dotfiles). This repo produces
  the image; consumers decide how to run it.
