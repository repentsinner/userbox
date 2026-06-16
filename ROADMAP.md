# ROADMAP: Userbox

## Kubernetes/compose client tooling

Derived from SPEC R3.

- **add-k8s-tooling**: Add `kubectl`, `helm`, `docker-compose` v2 (Go
  binary), and `kind` to the Containerfile in the appropriate install
  layers. Exporting to `~/.local/bin` happens via the distrobox `.ini`
  in the chezmoi dotfiles repo — coordinate the `exported_bins` change
  there. **Verify:** after rebuild and login, `kubectl version
  --client`, `helm version`, `docker-compose version`, and `kind
  version` resolve from the host PATH.
- **validate-kind-nesting**: Confirm `kind create cluster`, run via the
  exported wrapper, drives the host rootless podman and yields a working
  cluster. Depends on add-k8s-tooling. **Verify:** `kind create cluster`
  succeeds and `kubectl get nodes` shows Ready from the host shell. If
  nesting fails, document it and escalate `kind` to the host image
  (Tilefin S28), revising SPEC R3.
