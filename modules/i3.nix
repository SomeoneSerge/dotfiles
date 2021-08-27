{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.some.i3;
  some = config.some;
in
{
  options = {
    some.i3 = {
      enable = mkEnableOption "Someone's i3 setup";
      package = mkOption {
        type = types.package;
        default = pkgs.i3-gaps;
        description = ''
          i3 package to use
        '';
      };
      fontsize = mkOption {
        type = types.float;
        default = 10.0;
        description = ''
          Font size for i3 and i3bar
        '';
      };
      brightnessDelta = mkOption {
        type = types.int;
        default = 2;
        description = ''
          Stepsize for brightnessctl in per cent
        '';
      };
      batteryIndicator = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable battery indicator in i3status/etc
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    environment.pathsToLink = [ "/libexec" ];

    services.xserver.desktopManager.xfce = {
      enable = true;
      noDesktop = true;
      enableXfwm = false;
    };
    services.xserver.displayManager.defaultSession = "xfce+i3";
    services.xserver.windowManager.i3 = {
      enable = mkDefault true;
      package = mkDefault cfg.package;
      extraPackages = with pkgs; [ dmenu i3status-rust i3lock-fancy ];
    };
    environment.systemPackages = with pkgs; [ polkit_gnome ];
    security.polkit.enable = true;
    home-manager.users.${some.mainUser} =
      let
        someBg =
          "${pkgs.gnome.gnome-backgrounds}/share/backgrounds/gnome/Tree.jpg";
        nixosConfig = config;
      in
      ({ config, options, ... }:
        let hc = config; # home config
        in
        {
          xsession.pointerCursor = {
            name = "breeze_cursors";
            package = pkgs.breeze-qt5;
            size = 32;
          };
          home.file.".background-image".source = someBg;
          home.file."Pictures/Backgrounds/someBg.jpg".source = someBg;
          services.random-background.enable = true;
          services.random-background.imageDirectory = "%h/Pictures/Backgrounds";

          services.gnome-keyring.enable = true;
          services.gnome-keyring.components = [ "ssh" "secrets" "pkcs11" ];
          programs.alacritty = {
            enable = true;
            settings = {
              key_bindings = [{
                key = "Return";
                mods = "Control|Shift";
                action = "SpawnNewInstance";
              }];
              dynamic_title = true;
              font.size = mkDefault 8.0;
            };
          };
          services.flameshot.enable = true;
          programs.i3status-rust = {
            enable = true;
            bars = {
              bottom = {
                blocks = (lib.optional cfg.batteryIndicator {
                  block = "battery";
                  interval = 10;
                  format = "{percentage} {time}";
                }) ++ [
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
          services.dunst.enable = true;
          services.screen-locker = {
            enable = true;
            lockCmd = "${pkgs.i3lock-fancy}/bin/i3lock-fancy";
            xautolockExtraOptions = optionals some.autosuspend [
              "-killer"
              "'/run/current-system/systemd/bin/systemctl suspend'"
            ];
            inactiveInterval = 60;
          };
          xsession.windowManager.i3 =
            let
              i3Final = hc.xsession.windowManager.i3;
              i3Cfg = i3Final.config;
              refresh_i3status = "killall -SIGUSR1 i3status-rs";
            in
            {
              enable = true;
              package = cfg.package;
              extraConfig = ''
                exec --no-startup-id ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
              '';
              config.modifier = mkDefault "Mod4";
              config.keybindings = mkOptionDefault (
                let modifier = i3Cfg.modifier;
                in
                {
                  "${modifier}+h" = "focus left";
                  "${modifier}+j" = "focus down";
                  "${modifier}+k" = "focus up";
                  "${modifier}+l" = "focus right";
                  "${modifier}+Shift+h" = "move left";
                  "${modifier}+Shift+j" = "move down";
                  "${modifier}+Shift+k" = "move up";
                  "${modifier}+Shift+l" = "move right";
                  "${modifier}+x" = "exec ${pkgs.xautolock}/bin/xautolock -locknow";
                  "XF86AudioRaiseVolume" =
                    "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && ${refresh_i3status}";
                  "XF86AudioLowerVolume" =
                    "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && ${refresh_i3status}";
                  "XF86AudioMute" =
                    "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && ${refresh_i3status}";
                  "XF86AudioMicMute" =
                    "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && ${refresh_i3status}";
                  "Print" = "exec flameshot full -p $HOME/Pictures/";
                  "Control+Print" = "exec flameshot full -c -p $HOME/Pictures/";
                  "Shift+Print" = "exec flameshot gui";
                }
              );
              config.modes = mkOptionDefault {
                resize = {
                  "h" = "resize shrink width 10 px or 10 ppt";
                  "j" = "resize grow height 10 px or 10 ppt";
                  "k" = "resize shrink height 10 px or 10 ppt";
                  "l" = "resize grow width 10 px or 10 ppt";
                  "Escape" = "mode default";
                  "Return" = "mode default";
                };
              };
              config.fonts.names = mkDefault [ "Hasklig" "FontAwesome5Free" ];
              config.fonts.size = mkDefault cfg.fontsize;
              config.workspaceAutoBackAndForth = mkDefault true;
              config.terminal = mkDefault "alacritty";
              config.bars = mkDefault [{
                mode = "dock";
                position = "bottom";
                fonts = i3Cfg.fonts;
                statusCommand =
                  "i3status-rs .config/i3status-rust/config-bottom.toml";
              }];
              config.gaps.inner = mkDefault 10;
            };
        });
  };
}
