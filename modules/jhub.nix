{ config, lib, pkgs, ... }:

with builtins;
with lib;

let

  cfg = config.services.jhub;

  jupyterhubFhs = pkgs.buildFHSUserEnvBubblewrap {
    name = "jupyterhub-fhs-env";
    targetPkgs = pkgs': with pkgs'; (
      [
        cfg.jupyterhubEnv

      ]
      ++ (condaPatchelfLibs pkgs')
      ++ [ condaInstall ]
    );
    runScript = ''
      /bin/jupyterhub --config ${jupyterhubConfig}
    '';

    profile = with pkgs; ''
      export PATH=${installationPath}/bin:$PATH
      # Paths for gcc if compiling some C sources with pip
      export NIX_CFLAGS_COMPILE="-I${installationPath}/include"
      export NIX_CFLAGS_LINK="-L${installationPath}lib"
      # Some other required environment variables
      export FONTCONFIG_FILE=/etc/fonts/fonts.conf
      export QTCOMPOSE=${xorg.libX11}/share/X11/locale
      export LIBARCHIVE=${libarchive.lib}/lib/libarchive.so
      # Allows `conda activate` to work properly
      [[ -f "${condaSh}" ]] || conda-install || echo "Failed to conda-install"
      [[ -f "${condaSh}" ]] && source "${condaSh}" || echo "Failed to source ${condaSh}"
    '';
  };

  condaPatchelfLibs = pkgs: builtins.map (p: p.lib or p) (
    [
      pkgs.alsaLib
      pkgs.cups
      pkgs.gcc-unwrapped
      pkgs.libGL
    ] ++ (
      with pkgs.xorg; [
        libSM
        libICE
        libX11
        libXau
        libXdamage
        libXi
        libXrender
        libXrandr
        libXcomposite
        libXcursor
        libXtst
        libXScrnSaver
      ]
    ) ++ [ config.boot.kernelPackages.nvidia_x11 ] # FIXME: should link /run/opengl-driver/lib instead
  );

  installationPath = "${jupyterhubWorkDir}/conda";
  condaSh = "${installationPath}/etc/profile.d/conda.sh";

  condaInstallerSh = fetchurl {
    url = "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh";
    sha256 = "sha256:1m6x4s6n3xyal4s4v2i3kb0gcxvhf4a4q9qisgcv91a18cn5c5sh";
  };

  condaInstall = pkgs.runCommand "conda-install" { buildInputs = [ pkgs.makeWrapper ]; }
    ''
      mkdir -p $out/bin
      cp ${condaInstallerSh} $out/bin/miniconda-installer.sh
      chmod +x $out/bin/miniconda-installer.sh

      makeWrapper                            \
        $out/bin/miniconda-installer.sh      \
        $out/bin/conda-install               \
        --add-flags "-p ${installationPath}" \
        --add-flags "-b"
    '';


  jupyterhubExecStart = "${jupyterhubFhs}/bin/${jupyterhubFhs.name}";

  jupyterhubWorkDir = "/var/lib/${cfg.stateDirectory}";

  kernels = (
    pkgs.jupyter-kernel.create {
      definitions =
        if cfg.kernels != null
        then cfg.kernels
        else pkgs.jupyter-kernel.default;
    }
  );

  jupyterhubConfig = pkgs.writeText "jupyterhub_config.py" ''
    c.JupyterHub.bind_url = "http://${cfg.host}:${toString cfg.port}"

    c.JupyterHub.authenticator_class = "${cfg.authentication}"
    c.JupyterHub.spawner_class = "${cfg.spawner}"

    c.Spawner.default_url = '/lab'
    c.Spawner.cmd = "/bin/jupyterhub-singleuser"
    c.Spawner.environment = {
      'JUPYTER_PATH': '${kernels}:${installationPath}/.local/share/jupyter'
    }

    ${cfg.extraConfig}
  '';

  spawnerPackages = {
    "systemdspawner.SystemdSpawner" = ps: ps.jupyterhub-systemdspawner;
    "dockerspawner.DockerSpawner" = ps: ps.dockerspawner;
    "dockerspawner.SwarmSpawner" = ps: ps.dockerspawner;
    "dockerspawner.SystemUserSpawner" = ps: ps.dockerspawner;
    "jupyterhub.spawner.LocalProcessSpawner" = ps: ps.jupyterhub;
  };


  # Options that can be used for creating a jupyter kernel.
  kernelOptions = { lib }:
    (
      with lib;

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
    );
in
{
  meta.maintainers = with maintainers; [ ];

  options.services.jhub = {
    enable = mkEnableOption "Jupyterhub development server";

    user = mkOption {
      type = types.str;
      default = "jhub";
      description = ''
        User under which to run JupyterHub.
        Defaults to jhub, which is then created automatically and otherwise
        must already exist.
      '';
    };

    authentication = mkOption {
      type = types.str;
      default = "jupyterhub.auth.PAMAuthenticator";
      description = ''
        Jupyterhub authentication to use

        There are many authenticators available including: oauth, pam,
        ldap, kerberos, etc.
      '';
    };

    spawner = mkOption {
      type = types.enum (attrNames spawnerPackages);
      default = "jupyterhub.spawner.LocalProcessSpawner";
      description = ''
        Jupyterhub spawner to use

        There are many spawners available including: local process,
        systemd, docker, kubernetes, yarn, batch, etc.
      '';
    };

    spawnerPackage = mkOption {
      type = types.functionTo types.package;
      default = spawnerPackages.${cfg.spawner};
      description = ''
        A python package that provides the ${cfg.spawner} class
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra contents appended to the jupyterhub configuration

        See https://jupyterhub.readthedocs.io/en/stable/getting-started/config-basics.html
      '';
      example = literalExample ''
        c.SystemdSpawner.mem_limit = '8G'
        c.SystemdSpawner.cpu_limit = 2.0
      '';
    };

    jupyterhubEnv = mkOption {
      type = types.package;
      default = pkgs.python3.withPackages (
        ps: with ps; [
          jupyterlab
          jupyterhub
          (cfg.spawnerPackage ps)
        ]
      );
      description = ''
        Python environment to run jupyterhub

        Customizing will affect the packages available in the hub and
        proxy. This will allow packages to be available for the
        extraConfig that you may need. This will not normally need to
        be changed.
      '';
    };

    kernels = mkOption {
      type =
        types.attrsOf (
          types.submodule (
            kernelOptions { inherit lib; }
          )
        )
      ;

      default = {
        python3 = {
          displayName = "Petty python";
          argv = [ cfg.jupyterhubEnv.interpreter "-m" "ipykernel_launcher" "-f" "{connection_file}" ];
          language = "python";
        };
      };
      description = ''
        Declarative kernel config

        Kernels can be declared in any language that supports and has
        the required dependencies to communicate with a jupyter server.
        In python's case, it means that ipykernel package must always be
        included in the list of packages of the targeted environment.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8000;
      description = ''
        Port number Jupyterhub will be listening on
      '';
    };

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = ''
        Bind IP JupyterHub will be listening on
      '';
    };

    stateDirectory = mkOption {
      type = types.str;
      default = "jhub";
      description = ''
        Directory for jupyterhub state (token + database)
      '';
    };
  };

  config = mkMerge [
    (
      mkIf cfg.enable {
        users.users = mkIf (cfg.user == "jhub") {
          jhub = {
            isSystemUser = true;
            home = jupyterhubWorkDir;
            description = "Jupyterhub user";
            extraGroups = [ "shadow" ];
            shell = pkgs.bashInteractive;
          };
        };
        systemd.services.jhub = {
          description = "Jupyterhub development server";

          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Restart = "always";
            ExecStart = jupyterhubExecStart;
            User = cfg.user;
            StateDirectory = cfg.stateDirectory;
            WorkingDirectory = jupyterhubWorkDir;
          };
        };
      }
    )
  ];
}
