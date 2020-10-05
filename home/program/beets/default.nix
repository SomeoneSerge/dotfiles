{ config, lib, pkgs, ... }:

{
  programs.beets = {
    enable = true;
    package = with pkgs; (
      beets.override
      {
        enableConvert = true;
        enableLoadext = true;
        enableKeyfinder = true;
        enableFetchart = true;
        enableThumbnails = true;
      }
    );
    settings = {
      directory=  "~/Music";
      library = "~/.config/beets/library.db";
      plugins = [
        "fromfilename"
        "fetchart"
        "lyrics"
        "lastgenre"
        "web" "bpd"
        "duplicates"
        "discogs"
        "ftintitle"
        "badfiles"
      ];
      import = {
          move = true;
      };
    };
  };
}
