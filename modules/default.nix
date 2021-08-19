{ config, pkgs, lib, ... }:

with lib; {
  imports = [ ./i3.nix ./sane.nix ./connect.nix ./jhub.nix ];
  options = {
    some.mainUser = mkOption {
      default = "ss";
      type = types.str;
    };
    some.autosuspend = mkEnableOption "Enable various autosuspend defaults (e.g. xautlock will be called with `systemctl suspend` as a killer script)";
  };
}
