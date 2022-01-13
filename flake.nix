{
  description = "Someone's dotfiles";

  inputs = {
    nix.url = "github:NixOS/nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    neovim-nightly = { url = "github:neovim/neovim?dir=contrib"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mach-nix.url = "github:DavHau/mach-nix";
    nixGL = {
      url = "github:guibou/nixGL";
      flake = false;
    };
    openconnect-sso = {
      url = "github:vlaci/openconnect-sso";
      flake = false;
    };
    nixpkgs-update = {
      type = "github";
      owner = "ryantm";
      repo = "nixpkgs-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-registry = {
      type = "github";
      owner = "NixOS";
      repo = "flake-registry";
      flake = false;
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
    , flake-registry
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      inherit (nixpkgs.lib) mapAttrsToList genAttrs nixosSystem;

      # take neovim-nightly built with upstream's nixpkgs
      # (thus with upstream's libc)

      overlays = (import ./overlays { inherit nixGL nix; })
        ++ [
        neovim-nightly.overlay
        # python-language-server breaks with python39
        # (final: prev: { neovim = prev.neovim.override { python3 = final.python38; python3Packages = final.python38Packages; }; })
        (import "${openconnect-sso}/overlay.nix")
      ];
      pkgs = import nixpkgs { inherit system; };
      pkgsExt = import nixpkgs { inherit system overlays; };
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
          extraOptions = ''
            flake-registry = file://${flake-registry}/flake-registry.json
          '';
        };
      };
      m.allowUnfree = { nixpkgs.config.allowUnfree = true; };
      m.useOverlays = { nixpkgs.overlays = overlays; };
      m.enable-some = import ./modules;
      m.enable-hm = users: { config, pkgs, ... }: {
        imports = [ home-manager.nixosModules.home-manager ];
        home-manager.useGlobalPkgs = true;
        home-manager.users = genAttrs users (user: import ./home/default.nix);
      };
      m.enable-openconnect = { pkgs, ... }: {
        environment.systemPackages =
          [ pkgs.openconnect-sso ];
      };
    in
    rec {
      packages.${system} = {
        nix = nix.packages.${system}.nix;
        home-devbox = (pkgs.callPackage ./home/call-hm.nix {
          inherit home-manager;
          username = "serge";
          addModules = with m; [
            { some.devbox.enable = true; }
            useOverlays
            allowUnfree
          ];
        }).activationPackage;
        inherit (pkgsExt) napari neovim;
        pkgs = pkgsExt.stdenv.mkDerivation {
          name = "pkgs-passthru";
          src = throw "Don't build, use pkgs from passthru";
          passthru = pkgsExt;
        };
        pkgsUnfree = pkgsExt.stdenv.mkDerivation {
          name = "pkgs-passthru-unfree";
          src = throw "Don't build, use pkgs from passthru";
          passthru = import inputs.nixpkgs { inherit system overlays; config.allowUnfree = true; };
        };
        pkgsUnfreeUnstable = pkgsExt.stdenv.mkDerivation {
          name = "pkgs-passthru-unfree";
          src = throw "Don't build, use pkgs from passthru";
          passthru = import inputs.nixpkgs-unstable { inherit system overlays; config.allowUnfree = true; };
        };
      };
      apps.${system} = {
        home-devbox = {
          type = "app";
          program = "${self.packages.${system}.home-devbox}/activate";
        };
      };

      nixosConfigurations.ss-x230 = nixosSystem {
        system = "x86_64-linux";
        modules = with m; [
          allowUnfree
          useOverlays
          enable-some
          enable-openconnect
          pin-registry
          nixos-hardware.nixosModules.lenovo-thinkpad-x230
          ./hosts/ss-x230/configuration.nix
          (enable-hm [ "ss" ])
        ];
      };

      nixosConfigurations.lite21 = nixosSystem {
        system = "x86_64-linux";
        modules = with m; [
          useOverlays
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

      nixosConfigurations.ss-xps13 = nixosSystem {
        inherit system;
        modules = with m; [
          useOverlays
          enable-some
          enable-openconnect
          pin-registry
          nixos-hardware.nixosModules.dell-xps-13-9360
          ./hosts/ss-xps13/configuration.nix
          (enable-hm [ "ss" ])
          # { environment.systemPackages = [ nixpkgs-update.packages.${system}.nixpkgs-update ]; }
        ];
      };

      nixosConfigurations.cs-338 = nixosSystem {
        system = "x86_64-linux";
        modules = with m; [
          allowUnfree
          useOverlays
          enable-some
          enable-openconnect
          pin-registry
          nixos-hardware.nixosModules.common-cpu-amd
          ./hosts/cs-338/configuration.nix
          (enable-hm [ "ss" "kozluks1" ])
        ];
      };

      nixosConfigurations.x230-installer = nixosSystem {
        system = "x86_64-linux";
        modules = with m; [
          useOverlays
          "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
          {
            environment.systemPackages =
              [ nixosConfigurations.ss-x230.config.system.build.toplevel ];
          }
        ];
      };
    };
}
