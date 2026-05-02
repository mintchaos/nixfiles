{
  description = "I... flake here";

  nixConfig = {
    extra-substituters = [
      "https://vicinae.cachix.org"
      "https://niri.cachix.org"
    ];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    vicinae.url = "github:vicinaehq/vicinae";

    cider-mpris.url = "github:mintchaos/cider-mpris";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    seance = {
      url = "git+https://github.com/no1msd/seance?submodules=1";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      nixpkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      homeManagerExtraSpecialArgs = {
        inherit inputs nixpkgs-unstable;
      };
    in
    {
      nixosConfigurations.the-spine = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs nixpkgs-unstable; };
        modules = [
          ./common/desktop-niri.nix
          ./hosts/the-spine.nix
          ./hosts/the-spine-hardware-configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = homeManagerExtraSpecialArgs;
            home-manager.users.xian = import ./home/desktop.nix;
          }
        ];
      };

      homeConfigurations."xian@the-spine" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ inputs.niri.overlays.niri ];
        };
        extraSpecialArgs = homeManagerExtraSpecialArgs;
        modules = [
          inputs.niri.homeModules.niri
          ./home/desktop.nix
        ];
      };
    };
}
