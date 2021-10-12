{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types;
  cfg = config.some.nix-utils;
in
{
  options = {
    some.nix-utils.enable = mkOption {
      description = "Add Nix helper tools to the home environment";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      home-manager
      niv
      cachix
      nixpkgs-fmt
      nixpkgs-review
      nix-visualize
      nix-index
      nix-tree
      patchelf
    ];
  };
}
