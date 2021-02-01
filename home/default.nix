{ pkgs, home-manager, system, nixGL }:

let
  overlays = (import ../overlays { inherit pkgs nixGL; });
in {
  laptop = home-manager.lib.homeManagerConfiguration rec {
    inherit system;
    homeDirectory = "/home/nk";
    username = "nk";
    configuration = {pkgs, ...}: rec {
      imports = [
        overlays
        ./common.nix
        ./laptop.nix
      ];
      home = {
        inherit username homeDirectory;
      };
    };
  };
  devbox = home-manager.lib.homeManagerConfiguration rec {
    inherit system;
    homeDirectory = "/home/serge";
    username = "serge";
    configuration = {pkgs, ...}: rec {
      imports = [
        overlays
        ./common.nix
        ./devbox.nix
      ];
      home = {
        inherit username homeDirectory;
      };
    };
  };
}
