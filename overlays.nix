{ nixpkgs
, nixGL
, nix
, ...
} @ inputs:
let
  inherit (nixpkgs) lib;
in
[

  inputs.neovim-nightly.overlay
  (import "${inputs.openconnect-sso}/overlay.nix")
  (final: prev:
    let
      ps = final.python3Packages;
      napriPkgs = import ./pkgs/napari.nix;
    in
    rec {
      inherit (prev.callPackage nixGL { }) nixGLNvidia nixGLIntel nixGLDefault;

      alejandra = inputs.alejandra.defaultPackage.${prev.system};
      nixUpstream = inputs.nix.packages.${prev.system}.nix;
      nixpkgs-update = inputs.nixpkgs-update.packages.${prev.system}.nixpkgs-update;
      nix-visualize = ps.buildPythonPackage rec {
        name = "nix-visualize-${version}";
        version = "1.0.4";
        src = prev.fetchFromGitHub {
          owner = "craigmbooth";
          repo = "nix-visualize";
          rev = "ee6ad3cb3ea31bd0e9fa276f8c0840e9025c321a";
          sha256 = "sha256-nsD5U70Ue30209t4fU8iMLCHzNZo18wKFutaFp55FOw=";
        };
        propagatedBuildInputs = with ps; [
          matplotlib
          networkx
          pygraphviz
        ];
      };

      napari-console = ps.callPackage napriPkgs.napariConsolePkg { };
      napari-svg = ps.callPackage napriPkgs.napariSvgPkg { };
      cachey = ps.callPackage napriPkgs.cacheyPkg { };
      psygnal = ps.callPackage napriPkgs.psygnalPkg { };
      docstring-parser = ps.callPackage napriPkgs.docstringParserPkg { };
      magicgui = ps.callPackage napriPkgs.magicguiPkg { };
      superqt = ps.callPackage napriPkgs.superqtPkg { };
      napari-plugin-engine = ps.callPackage napriPkgs.napariPluginPkg { };
      napari = final.lib.callPackageWith
        (final // ps // final.libsForQt5)
        napriPkgs.napariPkg
        { inherit (final) pint; };

      saccade = final.libsForQt5.callPackage ./pkgs/saccade.nix { };

      pint = ps.callPackage ./pkgs/pint.nix { };

      vpn-slice = prev.vpn-slice.overrideDerivation (oldAttrs:
        with oldAttrs; rec {
          version = "0.15";
          src = final.fetchFromGitHub {
            owner = "dlenski";
            repo = pname;
            rev = "bf445f33f73c0a93745920c8cd46753b529923c8";
            sha256 = "Jk/qiMhBvaeqPFe1Xe3WMF/f4WoHfkjy+L0FoZPhYL4=";
          };
        });

      tor-browser-bundle-bin = prev.tor-browser-bundle-bin.override {
        pulseaudioSupport = true;
        mediaSupport = true;
      };
      logseq = prev.logseq.override { electron_13 = prev.electron_16; };
      gpytorch = prev.python3Packages.callPackage ./pkgs/gpytorch.nix { };
      gpflux = prev.python3Packages.callPackage ./pkgs/gpflux.nix { };
      dm-tree = prev.python3Packages.callPackage ./pkgs/dm-tree { };
      tfp15 = prev.python3Packages.callPackage ./pkgs/tfp.nix { inherit dm-tree; };
      gpflow = prev.python3Packages.callPackage ./pkgs/gpflow.nix { inherit keras; };
      trieste = prev.python3Packages.callPackage ./pkgs/trieste.nix { tensorflow-probability = tfp15; };
      # patchelf for big files...
      patchelfFromUnstable = prev.callPackage
        "${inputs.nixpkgs-unstable}/pkgs/development/tools/misc/patchelf/unstable.nix"
        { };
      bazelFromUnstable = lib.callPackageWith (prev // prev.darwin.apple_sdk.frameworks)
        "${inputs.nixpkgs-unstable}/pkgs/development/tools/build-managers/bazel/bazel_3/"
        {
          inherit (prev.darwin) cctools;
          bazel_self = bazelFromUnstable;
          buildJdk = prev.jdk11_headless;
          buildJdkName = "java11";
          runJdk = prev.jdk11_headless;
          stdenv =
            if prev.stdenv.cc.isClang
            then prev.llvmPackages.stdenv
            else prev.stdenv;
        };
      tensorflow-estimator = lib.callPackageWith (prev // prev.darwin.apple_sdk.frameworks // prev.python3Packages)
        "${inputs.nixpkgs-unstable}/pkgs/development/python-modules/tensorflow-estimator/"
        { };
      keras = lib.callPackageWith (prev // prev.python3Packages)
        "${inputs.nixpkgs-unstable}/pkgs/development/python-modules/keras/"
        { };

      conda = final.callPackage ./pkgs/conda.nix { };
    })
]
