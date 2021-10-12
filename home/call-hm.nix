{ pkgs, home-manager, username, homeDirectory ? "/home/${username}", addModules ? [ ], ... }:

(home-manager.lib.homeManagerConfiguration rec {
  inherit pkgs;
  inherit (pkgs) system;
  inherit username homeDirectory; # TODO: Is this really necessary?
  configuration = { pkgs, ... }@confInputs: rec {
    imports = [ ./default.nix ] ++ addModules;
    home = { inherit username homeDirectory; };
  };
})
