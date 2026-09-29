# omt-camera-bridge

Reads raw UYVY camera frames from the `c2` Python app over stdin and
streams them out over
[Open Media Transport](https://www.openmediatransport.org/) (OMT) so the
camera shows up as a source in OBS, vMix, etc. picamera2's "main" stream is
configured as UYVY natively (the vc4 ISP emits it directly), so there's no
pixel-format conversion here.

`c2` spawns this as a subprocess and writes frames straight to its stdin.
See `../c2/omtbridge.py` for the Python side that spawns and feeds it.

## Quick start

You can use a plain Rust toolchain (`rustup`) but [Nix](https://nixos.org/download/#download-nix) makes things arguably easier.


### Build

```bash
nix build
./result/bin/omt-camera-bridge
```

`nix build` always builds for your current machine's platform

### Dev shell

```bash
nix develop
```

this should set up everything you need for compiling the project.

```bash
# Build for the machine you're on right now - fast, uses your native linker
cargo build --release

# Cross-compile - use `cargo zigbuild` (not `cargo build`) for any target
# other than your host's. Zig acts as the C linker/toolchain for every
# target below, on any of the 4 host platforms, so no per-target system
# toolchain installs are needed.
cargo zigbuild --release --target aarch64-unknown-linux-musl   # Raspberry Pi (64-bit)
cargo zigbuild --release --target x86_64-unknown-linux-musl    # generic Linux x86_64
cargo zigbuild --release --target aarch64-apple-darwin         # Apple Silicon Mac
cargo zigbuild --release --target x86_64-apple-darwin          # Intel Mac
```

Cross-compiled binaries land under
`target/<target-triple>/release/omt-camera-bridge` as usual for Cargo.

We use musl to produce fully static binaries with zero runtime dependencies.

### Deploying to the Raspberry Pi

The Pi runs `aarch64-unknown-linux-musl`. From your dev machine:

```bash
cargo zigbuild --release --target aarch64-unknown-linux-musl
scp target/aarch64-unknown-linux-musl/release/omt-camera-bridge root@<pi-ip>:/opt/omt-camera-bridge/omt-camera-bridge
ssh root@<pi-ip> 'chmod +x /opt/omt-camera-bridge/omt-camera-bridge'
```

## Running it

`c2` spawns this (see `[omt_bridge]` in `camera.ini` / `c2/config.py`)
when `omt_bridge.enabled` is set, passing its own binary path, name, and
resolution/framerate as arguments.

```bash
omt-camera-bridge [--name NAME] [--width W] [--height H] [--fps N]
```

| Flag | Default | Meaning |
|---|---|---|
| `--name` | `C2 Camera` | OMT source name - shows up as `<hostname> (<name>)` in receivers |
| `--width` | `1920` | Must match the Python app's "main" stream width (must be even) |
| `--height` | `1080` | Must match the Python app's "main" stream height |
| `--fps` | `30` | Advertised frame rate (metadata only - actual rate follows whatever Python sends) |
