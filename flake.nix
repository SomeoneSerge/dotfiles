{
  description = "Someone's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager }@inputs: 
  let
    overlays = [ import ./overlays/pylinters.nix ];
    system = "x86_64-linux";
  in rec {
    homeManagerConfigurations = {
      intm = home-manager.lib.homeManagerConfiguration {
        configuration = import ./hosts/intm/home.nix;
        homeDirectory = "/home/nk";
        username = "nk";
        inherit system;
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      };
      anarchymachine = home-manager.lib.homeManagerConfiguration {
        configuration = import ./hosts/anarchymachine/home.nix;
        homeDirectory = "/home/serge";
        username = "serge";
        inherit system;
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system overlays;
        };
      };
    };
    defaultPackage.x86_64-linux = homeManagerConfigurations.intm.activationPackage;
    packages.x86_64-linux.activateIntm = homeManagerConfigurations.intm.activationPackage;
    packages.x86_64-linux.activateAnarchy = homeManagerConfigurations.anarchymachine.activationPackage;
  };
}
