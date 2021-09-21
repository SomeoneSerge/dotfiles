{
  description = "Someone's dotfiles";

  inputs = {
    nix.url = "github:NixOS/nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    neovim-nightly = { url = "github:neovim/neovim?dir=contrib"; };
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

  outputs =
    { self
    , nixpkgs
    , nix
    , home-manager
    , nixos-hardware
    , openconnect-sso
    , neovim-nightly
    , ...
    }@inputs:
    let
      system = "x86_64-linux";

      # take neovim-nightly built with upstream's nixpkgs
      # (thus with upstream's libc)
      neovimOverlay = final: prev:
        let system = prev.system;
        in { neovim-nightly = neovim-nightly.packages.${system}.neovim; };

      overlays = (import ./overlays { inherit system nixGL nix; })
        ++ [ neovimOverlay ];

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
      someModules = import ./modules;
    in
    rec {
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
          someModules
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
          someModules
          (home-manager.nixosModules.home-manager)
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.ss = {
              programs.ssh = {
                enable = true;
                matchBlocks = {
                  "*" = { identityFile = "/home/ss/.ssh/ss-lite21"; };
                };
              };
            };
          }
          ./hosts/lite21/configuration.nix
          pin-registry
        ];
      };

      nixosConfigurations.ss-xps13 = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [
          someModules
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
          someModules
          (home-manager.nixosModules.home-manager)
          nixos-hardware.nixosModules.common-cpu-amd
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.ss = (import ./home/common.nix);
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
