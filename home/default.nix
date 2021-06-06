{ system, pkgs, home-manager, nixGL, nix }:

{
  laptop = username:
    (home-manager.lib.homeManagerConfiguration rec {
      inherit system pkgs;
      homeDirectory = "/home/${username}";
      inherit username;
      configuration = { pkgs, ... }@confInputs: rec {
        imports = [ ./laptop.nix ];
        home = { inherit username homeDirectory; };
      };
    });
  devbox = home-manager.lib.homeManagerConfiguration rec {
    inherit system pkgs;
    homeDirectory = "/home/serge";
    username = "serge";
    configuration = { pkgs, ... }@confInputs: rec {
      imports = [ ./common.nix ./devbox.nix ];
      home = { inherit username homeDirectory; };
    };
  };
}
