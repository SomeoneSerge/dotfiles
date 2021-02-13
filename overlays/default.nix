{ system, pkgs, nixGL, nix }:

let
  addInjectGL = (final: prev: {
    inherit (nixGL) nixGLNvidia nixGLIntel nixGLDefault;
  });
  useModernNix = (final: prev: {
    inherit (nix.packages.${system}) nix;
  });
  addPythonLinters = (import ./pylinters.nix);
  overlays = {...}: {
    nixpkgs.overlays = [
      addInjectGL
      # useNixUnstable  -- this breaks cachix
      addPythonLinters
      useModernNix
    ];
  };
in overlays
