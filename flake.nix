{
  description = "I... flake here";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";

    opencode-flake.url = "github:aodhanhayter/opencode-flake";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations.the-spine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./common/desktop-niri.nix
          ./hosts/the-spine.nix
          ./hosts/the-spine-hardware-configuration.nix
          # ./common/desktop-wayland.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };

            home-manager.users.xian = import ./home/desktop.nix;
          }
        ];
      };

      homeConfigurations."xian@the-spine" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home/desktop.nix
          {
            home.username = "xian";
            home.homeDirectory = "/home/xian";
          }
        ];
      };
    };
}
