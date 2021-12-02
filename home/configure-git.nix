{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf optionalAttrs;
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    delta.enable = true;
    delta.options = {
      line-numbers = true;
      side-by-side = true;
    };
    extraConfig = {
      pager.log = "delta";
      pager.reflog = "delta";
      pager.show = "delta";
      pager.blame = "delta";
      diff.colorMoved = "default";
      pull.ff = "only";
      alias = {
        st = "status --short --untracked-files=no";
        fuckme = "reset --hard HEAD";
        fuckyou = "push --force";
        please = "push --force-with-lease";
      };
      color.ui = "auto";
      init.defaultBranch = "master";
    };
  } // optionalAttrs (config.home.username == "ss") {
    userName = "Someone Serge";
    userEmail = "sergei.kozlukov@aalto.fi";
  };
}
