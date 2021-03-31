{ config, pkgs, nixGL, ... }:

{
  imports = [
    ./common-nixutils.nix
    ./common-fileutils.nix
    ./common-gitutils.nix
    ./program/tmux/default.nix
    ./program/neovim/default.nix
  ];

  # Let's NOT let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
  home.stateVersion = "20.09";

  home.sessionVariables = {
    EDITOR = "nvim";
    FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };

  home.language.base = "en_US.UTF-8";
  home.packages = with pkgs; [
    nixModern /* imported in ../overlays/default.nix from NixOS/nix flake */

    less

    # Not installing mosh, because of
    # https://github.com/NixOS/nixpkgs/issues/90523
    # mosh
    htop

    asciinema
    youtubeDL

    patchelf
    stack
    bazel
    meson
    leiningen
    nodejs
    ccls
  ];

  programs.man = {
    enable = true;
    generateCaches = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    plugins = [
      {
        name = "zsh-autosuggestions";  # will source zsh-autosuggestions.plugin.zsh
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.6.4";
          sha256 = "xv4eleksJzomCtLsRUj71RngIJFw8+A31O6/p7i4okA=";
        };
       }
       {
         name = "enhancd";
         file = "init.sh";
         src = pkgs.fetchFromGitHub {
           owner = "b4b4r07";
           repo = "enhancd";
           rev = "v2.2.4";
           sha256 = "9/JGJgfAjXLIioCo3gtzCXJdcmECy6s59Oj0uVOfuuo=";
           };
        }
    ];
    initExtraBeforeCompInit = ''
      # From https://github.com/sorin-ionescu/prezto/issues/1245 but possibly useless
      function revert-expand-or-complete {
        zle expand-or-complete
      }

      zle -N expand-or-complete-with-indicator revert-expand-or-complete
      '';
  };

  programs.powerline-go = {
    enable = true;
    newline = false;
    modules = [ "nix-shell" "cwd" "git" ];
      # pathAliases = { "\\~/project/foo" = "prj-foo"; };
    settings = {
      cwd-max-depth = 2;
      git-mode = "simple";
      #   ignore-repos = [ "/home/me/project1" "/home/me/project2" ];
    };
  };

  programs.bash = {
    enable = true;
    sessionVariables = config.home.sessionVariables;
    bashrcExtra = '' . ${pkgs.bash-completion}/share/bash-completion/bash_completion
      PROMPT_COMMAND="history -a; history -r"
      '';
    shellOptions = [
      # Default
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
      "checkjobs"
      # Custom
      "dirspell"
      "cdspell"
    ];
  };

  programs.fzf = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableScDaemon = false;
  };
}
