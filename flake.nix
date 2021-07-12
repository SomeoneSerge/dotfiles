{
  description = "Someone's dotfiles";

  inputs = {
    nix.url = "github:NixOS/nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mach-nix.url = "github:DavHau/mach-nix";
    nixGL = {
      url = "github:guibou/nixGL";
      flake = false;
    };
    openconnect-sso = {
      url = "github:SomeoneSerge/openconnect-sso/flake.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix, home-manager, nixos-hardware, openconnect-sso
    , ... }@inputs:
    let
      system = "x86_64-linux";
      # Apparently, there are multiple nixpkgs spawned.
      # These nixpkgs are used to build home-manager.
      # Nixpkgs that home-manager configs get in their arguments are different
      overlays = (import ./overlays { inherit system nixGL nix; });
      pkgsArgs = { inherit system overlays; };
      pkgs = import nixpkgs pkgsArgs;
      pkgsUnfree = import nixpkgs (pkgsArgs // { config.allowUnfree = true; });

      nixGL = import inputs.nixGL { pkgs = pkgsUnfree; };

      homeCfgs = (pkgs.callPackage ./home/default.nix {
        inherit pkgs home-manager system nixGL nix;
      });
      openconnect-module = {
        environment.systemPackages =
          [ openconnect-sso.packages.${system}.openconnect-sso ];
      };
      registry = {
        dotfiles.flake = inputs.self;
        nixpkgs.flake = inputs.nixpkgs;
        mach-nix.flake = inputs.mach-nix;
      };
      pin-registry = { nix = { inherit registry; }; };
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
        pkgs = pkgsUnfree;
        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-x230
          (home-manager.nixosModules.home-manager)
          openconnect-module
          pin-registry
          ./hosts/ss-x230/configuration.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.ss =
              (import ./home/laptop.nix { inherit pkgs; });
          }
        ];
      };

      nixosConfigurations.lite21 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit pkgs;
        modules = [
          (home-manager.nixosModules.home-manager)
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.ss = {
                programs.ssh = {
                    enable = true;
                    matchBlocks = {
                        "*" = {
                            identityFile = "/home/ss/.ssh/ss-lite21";
                        };
                    };
                };
            };
          }
          ./hosts/lite21/configuration.nix
          pin-registry
        ];
      };

      nixosConfigurations.ss-xps13 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit pkgs;
        modules = [
          (home-manager.nixosModules.home-manager)
          nixos-hardware.nixosModules.dell-xps-13-9360
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.ss =
              (import ./home/laptop.nix { inherit pkgs; });
          }
          openconnect-module
          ./hosts/ss-xps13/configuration.nix
          pin-registry
        ];
      };

      nixosConfigurations.cs-338 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = pkgsUnfree;
        modules = [
          (home-manager.nixosModules.home-manager)
          nixos-hardware.nixosModules.common-cpu-amd
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.ss =
              (import ./home/common.nix { inherit pkgs; });
          }
          openconnect-module
          ./hosts/cs-338/configuration.nix
          pin-registry
        ];
      };

      nixosConfigurations.x230-installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit pkgs;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
          {
            environment.systemPackages =
              [ nixosConfigurations.ss-x230.config.system.build.toplevel ];
          }
        ];
      };
    };
}
