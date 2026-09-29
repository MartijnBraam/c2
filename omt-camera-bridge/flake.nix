{
  description = "omt-camera-bridge - streams c2 camera frames over Open Media Transport (OMT)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        # Targets the devShell's toolchain can build for, regardless of
        # which of the 4 supported host platforms you're on.
        crossTargets = [
          "x86_64-unknown-linux-musl"
          "aarch64-unknown-linux-musl"
          "x86_64-apple-darwin"
          "aarch64-apple-darwin"
        ];

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          targets = crossTargets;
        };

        craneLib = (crane.mkLib pkgs).overrideToolchain (_p: rustToolchain);

        src = craneLib.cleanCargoSource ./.;

        commonArgs = {
          inherit src;
          strictDeps = true;
        };

        cargoArtifacts = craneLib.buildDepsOnly commonArgs;

        omt-camera-bridge = craneLib.buildPackage (commonArgs // {
          inherit cargoArtifacts;
          pname = "omt-camera-bridge";
        });
      in
      {
        packages.default = omt-camera-bridge;
        packages.omt-camera-bridge = omt-camera-bridge;

        devShells.default = pkgs.mkShell {
          packages = [
            rustToolchain
            pkgs.cargo-zigbuild
            pkgs.zig
          ];
        };
      });
}
