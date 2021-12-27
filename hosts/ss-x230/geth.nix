{ config, lib, pkgs, ... }:

let
  inherit (lib) optionalString;
  gethName = "whyAreYouGeth";
  cfg = config.services.geth.${gethName};
in
{
  systemd.services."geth-${gethName}".script = lib.mkForce ''
    ${cfg.package}/bin/geth \
      --nousb \
      --syncmode ${cfg.syncmode} \
      --gcmode ${cfg.gcmode} \
      --port ${toString cfg.port} \
      --maxpeers ${toString cfg.maxpeers} \
      ${if cfg.http.enable then ''--http --http.addr ${cfg.http.address} --http.port ${toString cfg.http.port}'' else ""} \
      ${optionalString (cfg.http.apis != null) ''--http.api ${lib.concatStringsSep "," cfg.http.apis}''} \
      ${if cfg.websocket.enable then ''--ws --ws.addr ${cfg.websocket.address} --ws.port ${toString cfg.websocket.port}'' else ""} \
      ${optionalString (cfg.websocket.apis != null) ''--ws.api ${lib.concatStringsSep "," cfg.websocket.apis}''} \
      ${optionalString cfg.metrics.enable ''--metrics --metrics.addr ${cfg.metrics.address} --metrics.port ${toString cfg.metrics.port}''} \
      ${lib.escapeShellArgs cfg.extraArgs} \
      --datadir /var/lib/goethereum/${gethName}/${if (cfg.network == null) then "mainnet" else cfg.network}
  '';
}
