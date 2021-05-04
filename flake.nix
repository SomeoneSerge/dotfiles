{
  description = "Someone's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    pkgsArgs = { inherit system; };
    pkgs = import nixpkgs pkgsArgs;
    pkgsUnfree = import nixpkgs (pkgsArgs // { allowUnfree = true; });

    nixGL = import inputs.nixGL {
      pkgs = pkgsUnfree;
    };

    homeCfgs = (pkgs.callPackage ./home/default.nix {
      inherit pkgs home-manager system nixGL nix;
    });
  in {
    defaultPackage.${system} = homeCfgs.laptop.activationPackage;
    packages.${system} = {
      home-laptop = homeCfgs.laptop.activationPackage;
      home-devbox = homeCfgs.devbox.activationPackage;
      nix = nix.packages.${system}.nix;
    };
    apps.${system} = {
      home-laptop = {
        type = "app";
        program = "${self.packages.x86_64-linux.home-laptop}/activate";
      };
      home-devbox = {
        type = "app";
        program = "${self.packages.x86_64-linux.home-devbox}/activate";
      };
    };

    nixosConfigurations.ss-x230 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/ss-x230/configuration.nix ];
    };

    nixosConfigurations.lite21 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/lite21/configuration.nix ];
    };
  };
}
