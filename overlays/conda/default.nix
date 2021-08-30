{ lib
, stdenv
, fetchurl
, runCommand
, makeWrapper
, buildFHSUserEnv
, alsaLib
, cups
, libselinux
, libarchive
, libGL
, xorg
  # Conda installs its packages and environments under this directory
, installationPath ? "~/.conda"
  # Conda manages most pkgs itself, but expects a few to be on the system.
  # But shouldn't we always take X and GL from target platform's /run/opengl-driver?
, condaDeps ? (
    [
      stdenv.cc
      libselinux
      alsaLib
      cups
    ] ++ (
      with xorg; [
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
        libGL
      ]
    )
  )
  # Any extra nixpkgs you'd like available in the FHS env for Conda to use
, extraPkgs ? (pkgs: [ ])
, extraPkgsMulti ? (pkgs: [ ])
, # Whether to run installer automatically when one enters the conda-shell
  autoInstall ? true
, # Whether to use miniforge, mambaforge, or anaconda
  condaManager ? "miniforge"
, # Whether to use pypy3 or python3 (cython)
  condaPython ? "python3"
}:

let
  condaSh = "${installationPath}/etc/profile.d/conda.sh";
  notFound = (builtins.abort "Unsupported configuration");
  filterInstallers = installer:
    (installer.system == stdenv.targetPlatform.system)
    && (installer.conda == condaManager)
    && (installer.python == condaPython);
  installer' = lib.findFirst filterInstallers installers;
  installer = lib.findSingle filterInstallers notFound (lib.warn "Multiple versions of conda match the query" installer') installers;

  src = fetchurl { inherit (installer) url sha256; };

  installerCmd = runCommand "conda-install" { buildInputs = [ makeWrapper ]; }
    ''
      mkdir -p $out/bin
      cp ${src} $out/bin/miniconda-installer.sh
      chmod +x $out/bin/miniconda-installer.sh

      makeWrapper                            \
        $out/bin/miniconda-installer.sh      \
        $out/bin/conda-install               \
        --add-flags "-p ${installationPath}" \
        --add-flags "-b"
    '';

  profile = ''
    # Add conda to PATH
    export PATH=${installationPath}/bin:$PATH
    # Paths for gcc if compiling some C sources with pip
    export NIX_CFLAGS_COMPILE="-I${installationPath}/include"
    export NIX_CFLAGS_LINK="-L${installationPath}lib"
    # Some other required environment variables
    export FONTCONFIG_FILE=/etc/fonts/fonts.conf
    export QTCOMPOSE=${xorg.libX11}/share/X11/locale
    export LIBARCHIVE=${libarchive.lib}/lib/libarchive.so
    # Allows `conda activate` to work properly
  '' + (lib.optionalString autoInstall ''
    [[ -f ${condaSh} ]] || conda-install -u || echo "[E] Failed to conda-install" >&2
  '') + ''
    [[ -f ${condaSh} ]] && source ${condaSh} || echo "Activation script ${condaSh} doesn't exist, run conda-install" >&2
  '';

  targetPkgs = pkgs: (builtins.concatLists [ [ installerCmd ] condaDeps (extraPkgs pkgs) ]);

  installerType.options = with lib; {
    url = mkOption {
      type = types.str;
      example = "https://github.com/conda-forge/miniforge/releases/download/4.10.3-4/Miniforge-pypy3-4.10.3-4-Linux-x86_64.sh";
    };
    sha256 = mkOption {
      type = types.str;
      example = "0a02h9imjw9357x15m38s5skzyqi9sj92gfpj3kn497jiy8ylsf6";
    };
    system = mkOption {
      type = types.str;
      example = "x86_64-linux";
    };
    conda = mkOption {
      type = types.enum [ "miniforge" "mambaforge" "anaconda" ];
    };
    python = mkOption {
      type = types.enum [ "pypy3" "python3" ];
    };
    version = mkOption { type = types.str; };
  };

  installers = [
    {
      url = "https://github.com/conda-forge/miniforge/releases/download/4.10.3-4/Miniforge3-Linux-x86_64.sh";
      sha256 = "1gkh1b1zqjnvmmchcsq632jy199b5i6v6dxy8y60nval8dnnwqhk";
      system = "x86_64-linux";
      conda = "miniforge";
      python = "python3";
    }
    {
      url = "https://github.com/conda-forge/miniforge/releases/download/4.10.3-4/Miniforge-pypy3-4.10.3-4-Linux-x86_64.sh";
      sha256 = "0a02h9imjw9357x15m38s5skzyqi9sj92gfpj3kn497jiy8ylsf6";
      system = "x86_64-linux";
      conda = "miniforge";
      python = "pypy3";
    }
    {
      url = "https://github.com/conda-forge/miniforge/releases/download/4.10.3-4/Miniforge3-Linux-aarch64.sh";
      sha256 = "1llj0c78pc5w5v1grzq98qankm8ig0v7xsf4vh2zqphlv2g20dqj";
      system = "aarch64-linux";
      conda = "miniforge";
      python = "python3";
    }
    {
      url = "https://github.com/conda-forge/miniforge/releases/download/4.10.3-4/Miniforge3-Darwin-x86_64.sh";
      sha256 = "0xrdi7yixhhr7hmmcih36sdxppf9yj5sflpl5f31gnd3qcz5kgi1";
      system = "x86_64-darwin";
      conda = "miniforge";
      python = "python3";
    }
    {
      url = "https://github.com/conda-forge/miniforge/releases/download/4.10.3-4/Miniforge3-Darwin-arm64.sh";
      sha256 = "1zmfrkwmgns6zcqmqlkla1zzfzp2sxll43gkl3b95k7r5wbs4y80";
      system = "aarch64-darwin";
      conda = "miniforge";
      python = "python3";
    }
    {
      url = "https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-MacOSX-x86_64.sh";
      sha256 = "026mgj9bnbfqri0w2vakhcs85r7nylswci1ih39cgqj33xrfjvbq";
      system = "x86_64-linux";
      conda = "anaconda";
      python = "python3";
    }
  ];
in
buildFHSUserEnv {
  name = "conda-shell";

  inherit profile targetPkgs;
  multiPkgs = extraPkgsMulti;

  passthru = { condaInstaller = installerCmd; profile = profile; };

  meta = {
    description = "Conda is a package manager for Python";
    homepage = "https://conda.io/";
    platforms = lib.platforms.linux;
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jluttine bhipple ];
  };
}
