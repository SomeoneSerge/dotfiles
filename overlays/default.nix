{ nixpkgs, nixGL, nix, ... }@inputs:

let
  inherit (nixpkgs) lib;

  addInjectGL =
    (final: prev: { inherit (prev.callPackage nixGL { }) nixGLNvidia nixGLIntel nixGLDefault; });
  useModernNix = (final: prev: { nixModern = nix.packages.${prev.system}.nix; });
  vpnSliceReadonlyHosts = (final: prev: {
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
  });
  overlays = [
    addInjectGL
    # useNixUnstable  -- this breaks cachix
    useModernNix
    vpnSliceReadonlyHosts
    (import ./nix-visualize.nix)
    (import ./conda/overlay.nix)
    (import ./saccade.nix)
    (import ./napari.nix)
    (import ./pint.nix)
    (final: prev: {
      tor-browser-bundle-bin = prev.tor-browser-bundle-bin.override {
        pulseaudioSupport = true;
        mediaSupport = true;
      };
      gpytorch = prev.python3Packages.callPackage ./gpytorch.nix { };
      gpflux = prev.python3Packages.callPackage ./gpflux.nix { };
      dm-tree = prev.python3Packages.callPackage ./dm-tree { };
      tfp15 = prev.python3Packages.callPackage ./tfp.nix { inherit (final) dm-tree; };
      keras = lib.callPackageWith (prev // prev.python3Packages)
        "${inputs.nixpkgs-unstable}/pkgs/development/python-modules/keras/"
        { };
      gpflow = prev.python3Packages.callPackage ./gpflow.nix { inherit (final) keras; };
    })
  ];
in
overlays
