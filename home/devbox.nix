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

  services.gpg-agent = {
    pinentryFlavor = "tty";
  };

  home.packages = with pkgs; [
    pkgs.nixGLIntel
    # pkgs.nixGLNvidia
  ];
}
