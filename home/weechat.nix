{ pkgs, ... }:

{
  home.packages = [
    (pkgs.weechat.override {
      configure = { ... }: {
        init = ''
          /server add libera irc.libera.chat
          /set irc.server.freenode.addresses "irc.libera.chat/6697"
          /set irc.server.freenode.ssl on

          /set irc.server.freenode.nicks "someones"
          /set irc.server.freenode.username "someones"
          /set irc.server.freenode.realname "Someone S"

          /set irc.server.freenode.autoconnect on

          /set irc.look.smart_filter on
          /filter add irc_smart * irc_smart_filter *
        '';
      };
    })
  ];
}
