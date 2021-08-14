{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.cuda-env;
  fhs = pkgs.buildFHSUserEnv {
    name = "cuda-fhs";
    targetPkgs = pkgs:
      with pkgs; [
        cfg.cudaPackage
        cfg.nvidiaPackage
        git
        gitRepo
        gnupg
        autoconf
        curl
        procps
        gnumake
        utillinux
        m4
        gperf
        unzip
        libGLU
        libGL
        xorg.libXi
        xorg.libXmu
        freeglut
        xorg.libXext
        xorg.libX11
        xorg.libXv
        xorg.libXrandr
        zlib
        ncurses5
        stdenv.cc
        binutils
      ];
    multiPkgs = pkgs: with pkgs; [ zlib ];
    runScript = "bash";
    profile = ''
      export CUDA_PATH=${cfg.cudaPackage}
      # export LD_LIBRARY_PATH=${cfg.nvidiaPackage}/lib
      export EXTRA_LDFLAGS="-L/lib -L${cfg.nvidiaPackage}/lib"
      export EXTRA_CCFLAGS="-I/usr/include"
    '';
  };

  # breaks the build if added to the closure
  cudaFHSShell = pkgs.stdenv.mkDerivation {
    name = "cuda-fhs-shell";
    nativeBuildInputs = [ fhs ];
    shellHook = "exec cuda-fhs";
  };

  cudaShell = pkgs.stdenv.mkDerivation {
    name = "cuda-env-shell";

    buildInputs = with pkgs; [
      git
      gitRepo
      gnupg
      autoconf
      curl
      procps
      gnumake
      utillinux
      m4
      gperf
      unzip
      cfg.cudaPackage
      cfg.nvidiaPackage
      libGLU
      libGL
      xorg.libXi
      xorg.libXmu
      freeglut
      xorg.libXext
      xorg.libX11
      xorg.libXv
      xorg.libXrandr
      zlib
      ncurses5
      stdenv.cc
      binutils
    ];

    shellHook = ''
      export CUDA_PATH=${cfg.cudaPackage}
      # export LD_LIBRARY_PATH=${cfg.nvidiaPackage}/lib:${pkgs.ncurses5}/lib
      export EXTRA_LDFLAGS="-L/lib -L${cfg.nvidiaPackage}/lib"
      export EXTRA_CCFLAGS="-I/usr/include"
    '';
  };
in
{
  options = {
    programs.cuda-env = {
      enable = mkEnableOption "Dev environments for CUDA";
      enableShell =
        mkEnableOption "Enable cuda-shell (no fhs). Appears to be broken";
      cudaPackage = mkOption {
        type = types.package;
        default = pkgs.cudatoolkit_11_2;
      };
      nvidiaPackage = mkOption {
        type = types.package;
        default = config.hardware.nvidia.package;
      };
    };

  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ fhs ] ++ optional cfg.enableShell cudaShell;
  };
}
