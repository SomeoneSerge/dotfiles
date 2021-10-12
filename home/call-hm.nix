{ pkgs, home-manager }:

{ username, homeDirectory ? "/home/${username}", addModules ? [ ], ... }:
(home-manager.lib.homeManagerConfiguration rec {
  inherit system pkgs;
  inherit username homeDirectory; # TODO: Is this really necessary?
  configuration = { pkgs, ... }@confInputs: rec {
    imports = [ ./default.nix ] ++ addModules;
    home = { inherit username homeDirectory; };
  };
})
