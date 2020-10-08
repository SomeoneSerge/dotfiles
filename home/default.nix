{ nixpkgs, home-manager, system }:

{
  intm = home-manager.lib.homeManagerConfiguration {
    configuration = import ./intm.nix;
    homeDirectory = "/home/nk";
    username = "nk";
    inherit system;
  };
  devbox = home-manager.lib.homeManagerConfiguration {
    configuration = (import ./devbox.nix);
    homeDirectory = "/home/serge";
    username = "serge";
    inherit system;
  };
}
