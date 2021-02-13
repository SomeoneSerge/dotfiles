{ pkgs, home-manager, system, nixGL, nix }:

let
  overlays = (pkgs.callPackage ../overlays { inherit pkgs nixGL nix; });
  commonImports = {pkgs, ...}: [
    overlays
    ./common.nix
  ];
in {
  laptop = home-manager.lib.homeManagerConfiguration rec {
    inherit system;
    homeDirectory = "/home/nk";
    username = "nk";
    configuration = {pkgs, ...}@confInputs: rec {
      imports = (commonImports confInputs) ++ [
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
    configuration = {pkgs, ...}@confInputs: rec {
      imports = (commonImports confInputs) ++ [
        ./devbox.nix
      ];
      home = {
        inherit username homeDirectory;
      };
    };
  };
}
