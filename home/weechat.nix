{ pkgs, ... }:

{
  home.packages = [(
    pkgs.weechat.override {
      configure = { ... }: {
        init = ''
          /server add freenode chat.freenode.org
          /set irc.server.freenode.addresses "chat.freenode.net/7000"
          /set irc.server.freenode.ssl on

          /set irc.server.freenode.nicks "SomeoneSerge"
          /set irc.server.freenode.username "someone-serge"
          /set irc.server.freenode.realname "Serge K"

          /set irc.server.freenode.autoconnect on

          /set irc.look.smart_filter on
          /filter add irc_smart * irc_smart_filter *
        '';
      };
    }
  )];
}
