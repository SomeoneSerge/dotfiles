{ config, pkgs, lib, ... }:

with lib; {
  imports = [ ./i3.nix ];
  options = {
    some.mainUser = mkOption {
      default = "ss";
      type = types.str;
    };
  };
}
