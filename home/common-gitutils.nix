{ config, pkgs, ... }:

{

  home.packages = with pkgs; [ gist gitAndTools.hub gitAndTools.gh ];
  programs.git = {
    enable = true;
    userName = "Serge K";
    userEmail = "newkozlukov@gmail.com";
    extraConfig = {
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
  };

}
