{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption mkDefault types;
  cfg = config.home.modern-unix;
in
{
  options.home.modern-unix = {
    enable = mkOption {
      description = ''
        Enable modern busybox replacements as per
        https://github.com/ibraheemdev/modern-unix
      '';
      type = types.bool;
      default = true;
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      du-dust
      duf
      fd
      ag
      ripgrep
      choose
      gping
      procs
      dogdns
    ];
    programs.broot.enable = mkDefault true;
    programs.bat.enable = mkDefault true;
    programs.exa.enable = mkDefault true;
    programs.lsd.enable = mkDefault true;
    programs.git.delta.enable = mkDefault true;
    programs.zoxide.enable = mkDefault true;
  };
}
