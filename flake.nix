{
  description = "Rust-pyo3 codecov example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs
    , rust-overlay
    , utils
    , ...
    }: utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
              overlays = [rust-overlay.overlays.default];

      };
      toolchain = pkgs.rust-bin.fromRustupToolchainFile ./toolchain.toml;
      pythonPackages = pkgs.python3Packages;
    in
    {
      # Used by `nix develop`
      devShells.default = pkgs.mkShell
        {
          venvDir = "./.venv";
          # Use nightly cargo & rustc provided by fenix. Add for packages for the dev shell here
          buildInputs = with pkgs; [
            # rust
            toolchain
            # rust-analyzer-unwrapped

            # python
            pythonPackages.python
            pythonPackages.venvShellHook

            pkg-config
          ];

          # Specify the rust-src path (many editors rely on this)
            RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";

          # Run this command, only after creating the virtual environment
          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            pip install -r requirements.txt
          '';

          # Now we can execute any commands within the virtual environment.
          # This is optional and can be left out to run pip manually.
          postShellHook = ''
            # allow pip to install wheels
            unset SOURCE_DATE_EPOCH
            # add cargo-llvm-cov
            cargo install cargo-llvm-cov
          '';
        };
    }
    );
}

