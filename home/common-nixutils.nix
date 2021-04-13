{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixUnstable
    cachix
    # lorri
    niv
  ];

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

  # Ignored anyway, because "restricted setting"
  # and "untrusted user":

  # xdg.configFile."nix/nix.conf".text = ''
  #   experimental-features = nix-command flakes
  #   '';
}
