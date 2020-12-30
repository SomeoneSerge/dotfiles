{ pkgs, home-manager, system, nixGL }:

let
  injectGL = {...}: {
    nixpkgs.overlays = [
      (final: prev: {
        inherit (nixGL) nixGLNvidia nixGLIntel nixGLDefault;
      })
    ];
  };
in {
  intm = home-manager.lib.homeManagerConfiguration rec {
    inherit system;
    homeDirectory = "/home/nk";
    username = "nk";
    configuration = {pkgs, ...}: rec {
      imports = [
        ./intm.nix
        injectGL
      ];
      home = { inherit username homeDirectory; };
    };
  };
  devbox = home-manager.lib.homeManagerConfiguration rec {
    inherit system;
    homeDirectory = "/home/serge";
    username = "serge";
    configuration = {pkgs, ...}: rec {
      imports = [
        ./devbox.nix
        injectGL
      ];
      home = { inherit username homeDirectory; };
    };
  };
}
