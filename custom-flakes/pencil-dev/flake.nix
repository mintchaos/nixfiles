{
  description = "Pencil.dev — design tool packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        version = "1.1.55";
        cli-version = "0.2.5";
      in {
        packages = {
          pencil-gui = pkgs.callPackage ./pencil-gui.nix { inherit version; };
          pencil = pkgs.callPackage ./pencil-cli.nix { version = cli-version; };
        };
        defaultPackage = self.packages.${system}.pencil;
      }
    );
}
