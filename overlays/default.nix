{ system, nixGL, nix }:

let
  addInjectGL =
    (final: prev: { inherit (nixGL) nixGLNvidia nixGLIntel nixGLDefault; });
  useModernNix = (final: prev: { nixModern = nix.packages.${system}.nix; });
  addPythonLinters = (import ./pylinters.nix);
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
    addPythonLinters
    useModernNix
    vpnSliceReadonlyHosts
    (import ./nix-visualize.nix)
    (import ./conda/overlay.nix)
  ];
in
overlays
