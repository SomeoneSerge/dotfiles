{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.cuda-fhs;
  kernelPkgs = config.boot.kernelPackages;
  fhs = pkgs.buildFHSUserEnv {
    name = "cuda-fhs";
    targetPkgs = pkgs:
      with pkgs; [
        cfg.cudaPackage
        kernelPkgs.nvidia_x11
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
      # export LD_LIBRARY_PATH=${kernelPkgs.nvidia_x11}/lib
      export EXTRA_LDFLAGS="-L/lib -L${kernelPkgs.nvidia_x11}/lib"
      export EXTRA_CCFLAGS="-I/usr/include"
    '';
  };

  # breaks the build if added to the closure
  cudaShell = pkgs.stdenv.mkDerivation {
    name = "cuda-env-shell";
    nativeBuildInputs = [ fhs ];
    shellHook = "exec cuda-fhs";
  };
in {
  options = {
    programs.cuda-fhs = {
      enable = mkEnableOption "FHS environment for CUDA";
      cudaPackage = mkOption {
        type = types.package;
        default = pkgs.cudatoolkit_11_2;
      };
    };

  };
  config = mkIf cfg.enable { environment.systemPackages = [ fhs ]; };
}
