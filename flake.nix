{
  description = "Someone's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixGL ={
      url = "github:guibou/nixGL";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    nixGL = import inputs.nixGL {
      pkgs = import nixpkgs { allowUnfree = true; inherit system; };
    };
    homeCfgs = (import ./home/default.nix {
      inherit pkgs home-manager system nixGL;
    });
  in {
    defaultPackage.x86_64-linux = homeCfgs.intm.activationPackage;
    packages.x86_64-linux = {
      home-intm = homeCfgs.intm.activationPackage;
      home-devbox = homeCfgs.devbox.activationPackage;
    };
    apps.x86_64-linux = {
      home-intm = {
        type = "app";
        program = "${self.packages.x86_64-linux.home-intm}/activate";
      };
      home-devbox = {
        type = "app";
        program = "${self.packages.x86_64-linux.home-devbox}/activate";
      };
    };
  };
}
