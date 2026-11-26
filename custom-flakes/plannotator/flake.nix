{
  description = "Plannotator CLI packaged for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      version = "0.29.4";
      hash = "sha256-y3IFCu5IVjAncKxTV9DsxGEUdDOqWTDx+rd23zzoVg4=";
      plannotator = pkgs.callPackage ./plannotator.nix { inherit version hash; };
      app = {
        type = "app";
        program = "${plannotator}/bin/plannotator";
        meta.description = plannotator.meta.description;
      };
    in
    {
      packages.${system} = {
        inherit plannotator;
        default = plannotator;
      };

      apps.${system} = {
        plannotator = app;
        default = app;
      };

      checks.${system}.startup =
        pkgs.runCommand "plannotator-startup"
          {
            nativeBuildInputs = [
              pkgs.bash
              pkgs.gnugrep
            ];
          }
          ''
            bash ${./tests/startup.sh} ${plannotator}/bin/plannotator
            touch "$out"
          '';
    };
}
