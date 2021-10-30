{
  description = "Someone's dotfiles";

  inputs = {
    nix.url = "github:NixOS/nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
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
    nixpkgs-update = {
      type = "github";
      owner = "ryantm";
      repo = "nixpkgs-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nix
    , nixGL
    , home-manager
    , nixos-hardware
    , openconnect-sso
    , neovim-nightly
    , nixpkgs-update
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      inherit (nixpkgs.lib) mapAttrsToList genAttrs;

      # take neovim-nightly built with upstream's nixpkgs
      # (thus with upstream's libc)
      neovimOverlay = final: prev:
        let
          system = prev.system;
        in
        { neovim-nightly = neovim-nightly.packages.${system}.neovim; };

      overlays = (import ./overlays { inherit nixGL nix; })
        ++ [ neovimOverlay ];

      pkgsArgs = { inherit system overlays; };
      pkgs = import nixpkgs pkgsArgs;
      pkgsUnfree = import nixpkgs (pkgsArgs // { config.allowUnfree = true; });
      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        dotfiles.flake = inputs.self;
        nixgl.flake = inputs.nixGL;
        mach-nix.flake = inputs.mach-nix;
        nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
        nixpkgs-master.flake = inputs.nixpkgs-master;
      };
      m.pin-registry = { config, ... }: {
        nix = {
          inherit registry;
          nixPath = mapAttrsToList (name: value: "${name}=${value.flake}") config.nix.registry;
        };
      };
      m.enable-some = import ./modules;
      m.enable-hm = users: { config, pkgs, ... }: {
        imports = [ home-manager.nixosModules.home-manager ];
        home-manager.useGlobalPkgs = true;
        home-manager.users = genAttrs users (user: import ./home/default.nix);
      };
      m.enable-openconnect = {
        environment.systemPackages =
          [ openconnect-sso.packages.${system}.openconnect-sso ];
      };
    in
    rec {
      packages.${system} = {
        nix = nix.packages.${system}.nix;
        home-devbox = (pkgsUnfree.callPackage ./home/call-hm.nix {
          inherit home-manager;
          username = "serge";
          addModules = [{ some.devbox.enable = true; }];
        }).activationPackage;
        napari = pkgs.napari;
      };
      apps.${system} = {
        home-devbox = {
          type = "app";
          program = "${self.packages.${system}.home-devbox}/activate";
        };
      };

      nixosConfigurations.ss-x230 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = pkgsUnfree;
        modules = with m; [
          enable-some
          enable-openconnect
          pin-registry
          nixos-hardware.nixosModules.lenovo-thinkpad-x230
          ./hosts/ss-x230/configuration.nix
          (enable-hm [ "ss" ])
        ];
      };

      nixosConfigurations.lite21 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit pkgs;
        modules = with m; [
          enable-some
          enable-openconnect
          pin-registry
          ./hosts/lite21/configuration.nix
          (enable-hm [ "ss" ])
          {
            home-manager.users.ss.programs.ssh = {
              enable = true;
              matchBlocks = {
                "*" = { identityFile = "/home/ss/.ssh/ss-lite21"; };
              };
            };
          }
        ];
      };

      nixosConfigurations.ss-xps13 = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = with m; [
          enable-some
          enable-openconnect
          pin-registry
          nixos-hardware.nixosModules.dell-xps-13-9360
          ./hosts/ss-xps13/configuration.nix
          (enable-hm [ "ss" ])
          { environment.systemPackages = [ nixpkgs-update.packages.${system}.nixpkgs-update ]; }
        ];
      };

      nixosConfigurations.cs-338 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = pkgsUnfree;
        modules = with m; [
          enable-some
          enable-openconnect
          pin-registry
          nixos-hardware.nixosModules.common-cpu-amd
          ./hosts/cs-338/configuration.nix
          (enable-hm [ "ss" "kozluks1" ])
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
