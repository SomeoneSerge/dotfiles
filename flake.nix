{
  description = "Someone's dotfiles";

  inputs = {
    nixpkgs.url = "github:SomeoneSerge/nixpkgs/nixos-unstable";
    nix.url = "github:NixOS/nix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixGL ={
      url = "github:guibou/nixGL";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";
    /* Apparently, there are multiple nixpkgs spawned.
     * These nixpkgs are used to build home-manager.
     * Nixpkgs that home-manager configs get in their arguments are different
     */
    overlays = (import ./overlays { inherit system nixGL nix; });
    pkgsArgs = { inherit system overlays; };
    pkgs = import nixpkgs pkgsArgs;
    pkgs' = pkgs;
    pkgsUnfree = import nixpkgs (pkgsArgs // { allowUnfree = true; });

    nixGL = import inputs.nixGL {
      pkgs = pkgsUnfree;
    };

    homeCfgs = (pkgs.callPackage ./home/default.nix {
      inherit pkgs home-manager system nixGL nix;
    });
  in rec {
    defaultPackage.${system} = pkgs.pylinters;
    packages.${system} = {
      home-laptop = (homeCfgs.laptop "nk").activationPackage;
      home-devbox = homeCfgs.devbox.activationPackage;
      nix = nix.packages.${system}.nix;
      pylinters = pkgs.pylinters;
    };
    apps.${system} = {
      home-laptop = {
        type = "app";
        program = "${self.packages.${system}.home-laptop}/activate";
      };
      home-devbox = {
        type = "app";
        program = "${self.packages.${system}.home-devbox}/activate";
      };
    };

    nixosConfigurations.ss-x230 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      inherit pkgs;
      modules = [
          (home-manager.nixosModules.home-manager)
          { home-manager.useGlobalPkgs = true; }
          ./hosts/ss-x230/configuration.nix
      ];
    };

    nixosConfigurations.lite21 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      inherit pkgs;
      modules = [
          ./hosts/lite21/configuration.nix 
      ];
    };

    nixosConfigurations.ss-xps13 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      inherit pkgs;
      modules = [
          (home-manager.nixosModules.home-manager)
          {
              home-manager.useGlobalPkgs = true;
              home-manager.users.ss = (import ./home/laptop.nix { inherit pkgs; });
          }
          ./hosts/ss-xps13/configuration.nix
      ];
    };

    nixosConfigurations.x230-installer = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      inherit pkgs;
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
        {
          environment.systemPackages = [
            nixosConfigurations.ss-x230.config.system.build.toplevel
          ];
        }
      ];
    };
  };
}
