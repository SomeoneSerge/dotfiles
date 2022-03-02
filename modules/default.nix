{ config, pkgs, lib, ... }:

with lib; {
  imports = [ ./i3.nix ./sane.nix ./connect.nix ./jhub.nix ];
  options = {
    some.mainUser = mkOption {
      default = "ss";
      type = types.str;
    };
  };
}
