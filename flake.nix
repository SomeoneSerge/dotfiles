{
  description = "Someone's dotfiles";

  inputs =
    {
      # Heads-up for 22.05: following unstable now
      nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
      nixos-unstable.url = github:NixOS/nixpkgs/nixos-unstable;
      nixpkgs-master.url = github:NixOS/nixpkgs/master;

      nixpkgs-unfree = {
        url = github:SomeoneSerge/nixpkgs-unfree;
        inputs.nixpkgs.follows = "nixpkgs";
      };

      home-manager = {
        url = github:nix-community/home-manager/master;
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nixos-hardware = {
        url = github:NixOS/nixos-hardware/master;
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nixpkgs-review = {
        url = github:Mic92/nixpkgs-review/2.7.0;
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nixpkgs-update = {
        url = github:ryantm/nixpkgs-update/0.3.0;
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.nixpkgs-review.follows = "nixpkgs-review";
      };

      flake-registry = {
        url = github:NixOS/flake-registry;
        flake = false;
      };

      alejandra = {
        url = github:kamadorueda/alejandra;
        inputs.nixpkgs.follows = "nixpkgs";
      };

      hercules-ci-agent = {
        url = github:hercules-ci/hercules-ci-agent/hercules-ci-agent-0.9.3;
        inputs.nixpkgs.follows = "nixpkgs";
      };

      neovim-nightly = {
        url = github:neovim/neovim?dir=contrib;
        inputs.nixpkgs.follows = "nixpkgs";
      };
      mach-nix.url = github:DavHau/mach-nix;
      nixGL = {
        url = github:guibou/nixGL;
        flake = false;
      };
      openconnect-sso = {
        url = github:vlaci/openconnect-sso;
        flake = false;
      };
    };
  outputs =
    { self
    , nixpkgs
    , nixpkgs-unfree
    , ...
    } @ inputs:
    let
      system = "x86_64-linux";
      inherit (nixpkgs.lib) mapAttrsToList genAttrs nixosSystem;

      overlays = import ./overlays.nix inputs;

      registries = {
        default = {
          nixpkgs.flake = inputs.nixpkgs;
          dotfiles.flake = inputs.self;
          nixgl.flake = inputs.nixGL;
          mach-nix.flake = inputs.mach-nix;
          nixos-unstable.flake = inputs.nixos-unstable;
          nixpkgs-master.flake = inputs.nixpkgs-master;
        };
        unfree = {
          nixpkgs.flake = inputs.nixpkgs-unfree;
          dotfiles.flake = inputs.self;
          nixgl.flake = inputs.nixGL;
          mach-nix.flake = inputs.mach-nix;
          nixos-unstable.flake = inputs.nixos-unstable;
          nixpkgs-master.flake = inputs.nixpkgs-master;
        };
      };

      nixPathFromRegistry = mapAttrsToList (name: value: "${name}=${value.flake}");

      m.pinNixPath = { config, lib, ... }: {
        nix = {
          registry = lib.mkDefault registries.default;
          nixPath = nixPathFromRegistry config.nix.registry;
          extraOptions = ''
            flake-registry = file://${inputs.flake-registry}/flake-registry.json
          '';
        };
      };
      m.allowUnfree = { nixpkgs.config.allowUnfree = true; };
      m.cudaSupport = {
        nixpkgs.config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };
      m.useOverlays = { nixpkgs.overlays = overlays; };
      m.enableSomeModules = import ./modules;
      m.enableHM = users: { config
                          , pkgs
                          , ...
                          }: {
        imports = [ inputs.home-manager.nixosModules.home-manager ];
        home-manager.useGlobalPkgs = true;
        home-manager.users = genAttrs users (user: import ./home/default.nix);
      };
      m.enable-openconnect = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.openconnect-sso ];
      };
    in
    rec {

      packages.${system} =
        let
          pkgs = import nixpkgs { inherit system; };
          pkgsWithOverlays = import nixpkgs { inherit system overlays; };
        in
        {
          inherit (pkgsWithOverlays) neovim;
          inherit (pkgsWithOverlays.python3Packages) napari;

          home-devbox =
            (pkgs.callPackage ./home/call-hm.nix {
              inherit (inputs) home-manager;
              username = "serge";
              addModules = with m; [
                { some.devbox.enable = true; }
                useOverlays
                allowUnfree
                cudaSupport
                { home.sessionVariables.NIX_PATH = nixPathFromRegistry registries.unfree; }
              ];
            }).activationPackage;
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
          enableSomeModules
          enable-openconnect
          pinNixPath
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x230
          ./hosts/ss-x230/configuration.nix
          (enableHM [ "ss" ])
        ];
      };

      nixosConfigurations.lite21 = nixosSystem {
        system = "x86_64-linux";
        modules = with m; [
          useOverlays
          enableSomeModules
          pinNixPath
          ./hosts/lite21/configuration.nix
          (enableHM [ "ss" ])
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
          enableSomeModules
          enable-openconnect
          pinNixPath
          inputs.nixos-hardware.nixosModules.dell-xps-13-9360
          ./hosts/ss-xps13/configuration.nix
          (enableHM [ "ss" ])
        ];
      };

      nixosConfigurations.cs-338 = nixosSystem {
        system = "x86_64-linux";
        modules = with m; [
          { config._module.args = { inherit inputs; }; }
          allowUnfree
          cudaSupport
          useOverlays
          enableSomeModules
          enable-openconnect
          { nix.registry = registries.unfree; }
          pinNixPath
          inputs.nixos-hardware.nixosModules.common-cpu-amd
          ./hosts/cs-338/configuration.nix
          (enableHM [ "ss" ])
          inputs.hercules-ci-agent.nixosModules.multi-agent-service
        ];
      };

      nixosConfigurations.x230-installer = nixosSystem {
        system = "x86_64-linux";
        modules = with m; [
          useOverlays
          "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
          {
            environment.systemPackages = [ nixosConfigurations.ss-x230.config.system.build.toplevel ];
          }
        ];
      };
    };
}
