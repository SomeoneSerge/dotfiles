{ system, pkgs, home-manager, nixGL, nix }:

let
  overlays = (pkgs.callPackage ../overlays { inherit pkgs nixGL nix; });
  commonImports = [
    overlays
    ./common.nix
  ];
in {
  laptop = home-manager.lib.homeManagerConfiguration rec {
    inherit system;
    homeDirectory = "/home/nk";
    username = "nk";
    configuration = {pkgs, ...}@confInputs: rec {
      imports = commonImports ++ [
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
      imports = commonImports ++ [
        ./devbox.nix
      ];
      home = {
        inherit username homeDirectory;
      };
    };
  };
}
