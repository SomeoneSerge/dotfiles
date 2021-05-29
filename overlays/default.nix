{ system, nixGL, nix }:

let
  addInjectGL = (final: prev: {
    inherit (nixGL) nixGLNvidia nixGLIntel nixGLDefault;
  });
  useModernNix = (final: prev: {
    nixModern = nix.packages.${system}.nix;
  });
  addPythonLinters = (import ./pylinters.nix);
  overlays = [
      addInjectGL
      # useNixUnstable  -- this breaks cachix
      addPythonLinters
      useModernNix
  ];
in overlays
