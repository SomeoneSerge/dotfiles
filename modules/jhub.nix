{ config, lib, pkgs, ... }:

let
  cfg = config.services.jhub;

  inherit (builtins) attrNames map;
  inherit (lib)
    types
    mkOption
    mkEnableOption
    literalExpression
    mkIf
    optionalString
    concatMapStringsSep;

  authenticatorClasses.pam = "jupyterhub.auth.PAMAuthenticator";


  python = cfg.python.withPackages (
    ps: [
      ps.jupyterlab
      ps.jupyterhub
    ]
    ++ cfg.spawnerPackages ps
    ++ cfg.pythonPackages ps
  );

  fhs = pkgs.buildFHSUserEnv {
    name = "jhub-fhs-env";
    targetPkgs = pkgs': (
      [
        python
        pkgs'.conda.condaInstaller
        config.hardware.opengl.package
      ]
      ++ config.hardware.opengl.extraPackages
      ++ cfg.extraPackages pkgs'

    );
    runScript = ''
      /bin/jupyterhub --config ${jhubConfig}
    '';
    profile = ''
      ${pkgs.conda.profile}

      ${cfg.profileExtra}
    '';
  };
  workDir = "/var/lib/${cfg.stateDirectory}";
  systemdExecStart = "${fhs}/bin/${fhs.name}";
  pidFile = "${workDir}/jupyterhub-proxy.pid";
  removeProxyPIDFile = pkgs.writeScript "remove-jupyterhub-proxy-pid" ''
    if [[ -f "${pidFile}" ]] ; then
      pid=$(cat '${pidFile}')
      pname=$(${pkgs.ps}/bin/ps -p "$pid" -o comm= || echo none)
      echo "Removing ${pidFile} (contents: $pid) (processes with that pid: $pname)"
      rm ${pidFile}
    fi
  '';

  kernels = (
    pkgs.jupyter-kernel.create {
      definitions =
        if cfg.kernels != null
        then cfg.kernels
        else pkgs.jupyter-kernel.default;
    }
  );

  jhubConfig =
    let
      content = ''
        c.JupyterHub.bind_url = "http://${cfg.host}:${toString cfg.port}"

        c.JupyterHub.authenticator_class = "${authenticatorClass}"
        c.JupyterHub.spawner_class = "${cfg.spawner}"

        c.Spawner.default_url = '/lab'
        c.Spawner.cmd = "/bin/jupyterhub-singleuser"
        c.Spawner.environment = {
          'JUPYTER_PATH': '${kernels}'
        }

      '' + optionalString (cfg.authenticator == "pam") ''
        c.Authenticator.allowed_users = {${allowedUsers}}
        c.LocalAuthenticator.create_system_users = False
        c.PAMAuthenticator.open_sessions = False
      '' + cfg.extraConfig;
      authenticatorClass = authenticatorClasses.${cfg.authenticator};
      quote = x: "'${x}'";
      allowedUsers = concatMapStringsSep ", " quote cfg.pam.allowedUsers;
    in
    pkgs.writeText "jupyterhub_config.py" content;

  spawnerPackages = {
    "systemdspawner.SystemdSpawner" = ps: [ ps.jupyterhub-systemdspawner ];
    "dockerspawner.DockerSpawner" = ps: [ ps.dockerspawner ];
    "dockerspawner.SwarmSpawner" = ps: [ ps.dockerspawner ];
    "dockerspawner.SystemUserSpawner" = ps: [ ps.dockerspawner ];
    "jupyterhub.spawner.LocalProcessSpawner" = _: [ ];
  };

  kernelOptions = import ./jupyter-kernel.nix;

  options.services.jhub.enable = mkEnableOption "Jupyterhub development server";
  options.services.jhub.user = mkOption {
    type = types.str;
    default = "jhub";
    description = ''
      User under which to run JupyterHub.
      Defaults to jhub, which is then created automatically and otherwise
      must already exist.
    '';
  };
  options.services.jhub.python = mkOption {
    type = types.package;
    default = pkgs.python3;
    description = ''
      Python interpreter to run jupyterhub and proxy with (must have "withPackages" attr)
    '';
  };
  options.services.jhub.pam.allowedUsers = mkOption {
    type = types.listOf types.str;
    default = [ ];
  };
  options.services.jhub.authenticator = mkOption {
    type = types.enum [ "pam" ];
    default = "pam";
    description = ''
      Jupyterhub Authenticator to use. Only PAM is supported
    '';
  };
  options.services.jhub.spawner = mkOption {
    type = types.enum (attrNames spawnerPackages);
    default = "jupyterhub.spawner.LocalProcessSpawner";
    description = ''
      Jupyterhub spawner to use: local process, systemd, docker, kubernetes,
      yarn, batch, etc
    '';
  };
  options.services.jhub.spawnerPackages = mkOption {
    type = types.functionTo (types.listOf types.package);
    default = spawnerPackages.${cfg.spawner};
    description = ''
      A python package that provides the ${cfg.spawner} class
    '';
  };
  options.services.jhub.extraConfig = mkOption {
    type = types.lines;
    default = "";
    description = ''
      Extra contents appended to the jupyterhub configuration

      See https://jupyterhub.readthedocs.io/en/stable/getting-started/config-basics.html
    '';
    example = literalExpression ''
      c.SystemdSpawner.mem_limit = '8G'
      c.SystemdSpawner.cpu_limit = 2.0
    '';
  };
  options.services.jhub.profileExtra = mkOption {
    type = types.lines;
    default = "";
    description = ''
      Commands to appens to FHS env's .profile
    '';
  };
  options.services.jhub.pythonPackages = mkOption {
    type = types.functionTo (types.listOf types.package);
    default = ps: with ps; [
      jupyterlab-pygments
      jupyterlab-widgets

      numpy
      matplotlib
      networkx
      pygraphviz
      joblib
      scikit-learn
      cufflinks
      plotly
    ];
    description = ''
      Python packages to add to the jupyterhub's host environment
      (in addition to notebook, jupyterhub, spawner, etc)
    '';
  };
  options.services.jhub.extraPackages = mkOption {
    type = types.functionTo (types.listOf types.package);
    default = pkgs: [ ];
    description = ''
      Extra packages to add to the FHS environment
    '';
  };
  options.services.jhub.kernels = mkOption {
    type =
      types.attrsOf (
        types.submodule (
          kernelOptions { inherit lib pkgs; }
        )
      )
    ;

    default = {
      python3 = {
        displayName = "Unfortunately Python";
        argv = [ python.interpreter "-m" "ipykernel_launcher" "-f" "{connection_file}" ];
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
  options.services.jhub.port = mkOption {
    type = types.port;
    default = 8000;
    description = ''
      Port number Jupyterhub will be listening on
    '';
  };
  options.services.jhub.host = mkOption {
    type = types.str;
    default = "127.0.0.1";
    description = ''
      Bind IP JupyterHub will be listening on
    '';
  };
  options.services.jhub.stateDirectory = mkOption {
    type = types.str;
    default = "jhub";
    description = ''
      Directory for jupyterhub state (token + database)
    '';
  };
in
{
  meta.maintainers = [ lib.maintainers.SomeoneSerge ];

  inherit options;

  config = mkIf cfg.enable
    {
      users.users = mkIf (cfg.user == "jhub") {
        jhub = {
          isSystemUser = true;
          home = workDir;
          description = "Jupyterhub user";
          extraGroups = [ "shadow" ];
          shell = pkgs.bashInteractive;
          group = "jhub";
        };
      };
      users.groups.jhub = { };
      systemd.services.jhub = {
        description = "Jupyterhub development server";

        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Restart = "always";
          ExecStart = systemdExecStart;
          ExecStopPost = removeProxyPIDFile;
          User = cfg.user;
          Group = "jhub";
          SupplementaryGroups = [ "shadow" ];
          StateDirectory = cfg.stateDirectory;
          WorkingDirectory = workDir;
          Slice = "jhub.slice";
          PrivateDevice = false;
        };
      };
    }

  ;
}
