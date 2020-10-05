{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';
}
