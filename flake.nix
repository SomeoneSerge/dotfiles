{
  description = "Someone's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager }@inputs: 
  let
    system = "x86_64-linux";
  in {
    homeManagerConfigurations = {
      intm = home-manager.lib.homeManagerConfiguration {
        configuration = import ./hosts/intm/home.nix;
        homeDirectory = "/home/nk";
        username = "nk";
        inherit system;
      };
      anarchymachine = home-manager.lib.homeManagerConfiguration {
        configuration = ({ config, pkgs, ...}:
          {
            nixpkgs.config.allowUnfree = true;
          }
          // (import ./home-common.nix {inherit config pkgs; }));
        homeDirectory = "/home/serge";
        username = "serge";
        inherit system;
      };
    };
    defaultPackage.x86_64-linux = self.homeManagerConfigurations.intm.activationPackage;
    packages.x86_64-linux.homeIntm = self.homeManagerConfigurations.intm.activationPackage;
    packages.x86_64-linux.homeAnarchy = self.homeManagerConfigurations.anarchymachine.activationPackage;
  };
}
