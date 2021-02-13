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
    pkgsArgs = { inherit system; overlays = [nix.overlay]; };
    pkgs = import nixpkgs pkgsArgs;
    nixGL = import inputs.nixGL {
      pkgs = import nixpkgs (pkgsArgs // { allowUnfree = true; });
    };
    homeCfgs = (pkgs.callPackage ./home/default.nix {
      inherit pkgs home-manager system nixGL nix;
    });
  in {
    defaultPackage.${system} = homeCfgs.laptop.activationPackage;
    packages.${system} = {
      home-laptop = homeCfgs.laptop.activationPackage;
      home-devbox = homeCfgs.devbox.activationPackage;
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
  };
}
