{ nixGL, nix }:

let
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
    # FIX: building logseq on nixos-21.05 fails with "electron_11 is EOL"
    (final: prev: { logseq = prev.logseq.override { electron = final.electron_12; }; })
  ];
in
overlays
