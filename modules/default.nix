{ config, pkgs, lib, ... }:

with lib; {
  imports = [ ./i3.nix ];
  options = {
    something.mainUser = mkOption {
      default = "ss";
      type = types.str;
    };
  };
}
