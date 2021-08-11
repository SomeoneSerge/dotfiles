{ config, pkgs, lib, ... }:

with lib;

let cfg = config.something.i3;
in {
  options = {
    something.i3 = {
      enable = mkEnableOption "Someone's i3 setup";
      brightnessDelta = mkOption {
        type = types.int;
        default = 2;
        description = ''
          Stepsize for brightnessctl in per cent
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    environment.pathsToLink = [ "/libexec" ];
    services.xserver.displayManager.defaultSession = "none+i3";
    services.xserver.windowManager.i3 = {
      enable = mkDefault true;
      package = mkDefault pkgs.i3-gaps;
      extraPackages = with pkgs; [ dmenu i3status-rust i3lock-fancy ];
    };
    environment.systemPackages = with pkgs; [ alacritty polkit_gnome ];
    security.polkit.enable = true;
    home-manager.users.${config.something.mainUser} = let
      someBg =
        "${pkgs.gnome.gnome-backgrounds}/share/backgrounds/gnome/Tree.jpg";
      nixosConfig = config;
    in ({ config, options, ... }:
      let hc = config; # home config
      in {
        home.file.".background-image".source = someBg;
        home.file."Pictures/Backgrounds/someBg.jpg".source = someBg;
        services.random-background.enable = true;
        services.random-background.imageDirectory = "%h/Pictures/Backgrounds";
        services.gnome-keyring.enable = true;
        services.gnome-keyring.components = [ "ssh" "secrets" "pkcs11" ];
        programs.i3status-rust = {
          enable = true;
          bars = {
            bottom = {
              blocks = [
                {
                  block = "disk_space";
                  path = "/";
                  alias = "/";
                  info_type = "available";
                  unit = "GB";
                  interval = 60;
                  warning = 20.0;
                  alert = 10.0;
                }
                {
                  block = "memory";
                  display_type = "memory";
                  # format_mem = "{Mup}%";
                  format_swap = "{SUp}%";
                }
                {
                  block = "cpu";
                  interval = 1;
                }
                {
                  block = "load";
                  interval = 1;
                  format = "{1m}";
                }
                { block = "sound"; }
                {
                  block = "time";
                  interval = 60;
                  format = "%a %d/%m %R";
                }
              ];
              settings = {
                theme = {
                  name = "solarized-dark";
                  overrides = {
                    idle_bg = "#123456";
                    idle_fg = "#abcdef";
                  };
                };
              };
              icons = "awesome5";
              theme = "gruvbox-dark";
            };

          };
        };
        xsession.windowManager.i3 = {
          enable = true;
          package = pkgs.i3-gaps;
          config = rec {
            modifier = "Mod4";
            keybindings = mkOptionDefault {
              "${modifier}+h" = "focus left";
              "${modifier}+j" = "focus down";
              "${modifier}+k" = "focus up";
              "${modifier}+l" = "focus right";
              "${modifier}+Shift+h" = "move left";
              "${modifier}+Shift+j" = "move down";
              "${modifier}+Shift+k" = "move up";
              "${modifier}+Shift+l" = "move right";
              "${modifier}+x" = "exec i3lock-fancy";
            };
            modes = mkOptionDefault {
              resize = {
                "h" = "resize shrink width 10 px or 10 ppt";
                "j" = "resize grow height 10 px or 10 ppt";
                "k" = "resize shrink height 10 px or 10 ppt";
                "l" = "resize grow width 10 px or 10 ppt";
                "Escape" = "mode default";
                "Return" = "mode default";
              };
            };
            workspaceAutoBackAndForth = true;
            terminal = "alacritty";
            bars = [{
              mode = "dock";
              position = "bottom";
              statusCommand =
                "i3status-rs .config/i3status-rust/config-bottom.toml";
            }];
          };
          extraConfig = ''
            exec --no-startup-id ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
          '';
        };
      });
  };
}
