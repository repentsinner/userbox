# ROADMAP: Userbox

## Flutter Linux build toolchain

### §road:flutter-build-deps

Add Flutter Linux build dependencies to the Containerfile as a
separate `RUN`/layer. Resolve the spec's requirement ("whatever
system packages are needed for `flutter doctor` to report a working
Linux toolchain") to concrete Fedora 42 package names.

Affected file: `Containerfile`.

§spec: R1 (Flutter Linux build toolchain)

**Verify:** Inside a running userbox container with an FVM-managed
Flutter SDK on `PATH`, run `flutter doctor -v`. The "Linux toolchain"
section shall report all checks passing — no missing tools, no
missing headers, `eglinfo` accessible.
