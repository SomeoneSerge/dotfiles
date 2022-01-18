{ lib, pkgs, ... }:

let
  inherit (lib) types mkOption;
in
{
  options = {

    displayName = mkOption {
      type = types.str;
      default = "";
      example = [
        "Python 3"
        "Python 3 for Data Science"
      ];
      description = ''
        Name that will be shown to the user.
      '';
    };

    argv = mkOption {
      type = types.listOf types.str;
      description = ''
        Command and arguments to start the kernel.
      '';
    };

    language = mkOption {
      type = types.str;
      example = "python";
      description = ''
        Language of the environment. Typically the name of the binary.
      '';
    };

    logo32 =
      let
        py3 = pkgs.python3.withPackages (ps: [ ps.ipykernel ]);
      in
      mkOption {
        type = types.nullOr types.path;
        default = "${py3}/${py3.sitePackages}/ipykernel/resources/logo-32x32.png";
        description = ''
          Path to 32x32 logo png.
        '';
      };
    logo64 =
      let
        py3 = pkgs.python3.withPackages (ps: [ ps.ipykernel ]);
      in
      mkOption {
        type = types.nullOr types.path;
        default = "${py3}/${py3.sitePackages}/ipykernel/resources/logo-64x64.png";
        description = ''
          Path to 64x64 logo png.
        '';
      };
  };
}

