{ pkgs, nixGL }:

let
  addInjectGL = (final: prev: {
    inherit (nixGL) nixGLNvidia nixGLIntel nixGLDefault;
  });
  useNixUnstable = (final: prev: {
    nix = prev.nixUnstable;
  });
  addPythonLinters = (import ./pylinters.nix);
  overlays = {...}: {
    nixpkgs.overlays = [
      addInjectGL
      # useNixUnstable  -- this breaks cachix
      addPythonLinters
    ];
  };
in overlays
