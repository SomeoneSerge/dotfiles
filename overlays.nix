{ nixpkgs
, nixGL
, ...
} @ inputs:
let
  inherit (nixpkgs) lib;
in
[

  inputs.neovim-nightly.overlay
  (import "${inputs.openconnect-sso}/overlay.nix")
  (final: prev:
    rec {
      inherit (prev.callPackage nixGL { }) nixGLNvidia nixGLIntel nixGLDefault;

      rycee = import inputs.rycee { pkgs = final; };

      obs-v4l2sink = final.libsForQt5.callPackage ./pkgs/obs-v4l2sink.nix { };
      alejandra = inputs.alejandra.defaultPackage.${prev.system};
      nixUpstream = inputs.nix.packages.${prev.system}.nix;

      saccade = final.libsForQt5.callPackage ./pkgs/saccade.nix { };

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

      conda = final.callPackage ./pkgs/conda.nix { };

      python3 =
        let
          self = prev.python3.override {
            inherit self;
            packageOverrides = nixpkgs.lib.composeManyExtensions final.pythonPackagesOverlays;
          }; in
        self;
      python3Packages = final.python3.pkgs;

      pythonPackagesOverlays = (prev.pythonPackagesOverlays or [ ]) ++ [
        (python-final: python-prev:
          {
            gpytorch = python-final.callPackage ./pkgs/gpytorch.nix { };
            gpflux = python-final.callPackage ./pkgs/gpflux.nix { };
            tfp15 = python-final.callPackage ./pkgs/tfp.nix { };
            gpflow = python-final.callPackage ./pkgs/gpflow.nix { };
            trieste = python-final.callPackage ./pkgs/trieste.nix { tensorflow-probability = python-final.tfp15; };

            chainer = python-prev.chainer.overridePythonAttrs (a: {
              postPatch = ''
                substituteInPlace chainer/_version.py --replace ",<8.0.0" ""
              '';
              meta = a.meta // {
                broken = false;
              };
            });

            nix-visualize = python-final.buildPythonPackage rec {
              name = "nix-visualize-${version}";
              version = "1.0.4";
              src = prev.fetchFromGitHub {
                owner = "craigmbooth";
                repo = "nix-visualize";
                rev = "ee6ad3cb3ea31bd0e9fa276f8c0840e9025c321a";
                sha256 = "sha256-nsD5U70Ue30209t4fU8iMLCHzNZo18wKFutaFp55FOw=";
              };
              propagatedBuildInputs = with python-final; [
                matplotlib
                networkx
                pygraphviz
              ];
            };

            pint = python-final.callPackage ./pkgs/pint.nix { };

            pycurl = python-prev.pycurl.overridePythonAttrs (a:
              # Fails? The patch has probably already been merged in nixpkgs, time to remove it
              assert a.version == "7.45.1";
              {
                disabledTests = a.disabledTests ++ [
                  "test_getinfo_raw_certinfo"
                  "test_request_with_certinfo"
                  "test_request_with_verifypeer"
                  "test_request_without_certinfo"
                ];
              });

            # FIXME: rm after https://github.com/NixOS/nixpkgs/issues/170080
            jupyterlab_server = python-prev.jupyterlab_server.overridePythonAttrs (a: {
              doCheck = false;
            });
          }
        )
      ];
    })
]
