{ config, lib, pkgs, ... }:

let
  inherit (lib) optionalString nameValuePair mapAttrs';
  eachGeth = lib.mapAttrs (name: extraCfg: { cfg = config.services.geth.${name}; inherit extraCfg; }) config.some.geth;
  scriptForUnit = gethName: cfgs:
    let inherit (cfgs) cfg extraCfg; in
    ''
      ${cfg.package}/bin/geth \
        --nousb \
        ${optionalString (!extraCfg.enableIpc) "--ipcdisable"} \
        ${optionalString (cfg.network != null) ''--${cfg.network}''} \
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
  unitForGeth = gethName: cfgs@{ cfg, extraCfg }: (
    nameValuePair "geth-${gethName}"
      {
        script = lib.mkIf cfg.enable (lib.mkForce (scriptForUnit gethName cfgs));
      }
  );
  extraGethOpts = { config, name, lib, ... }: {
    options.enableIpc = lib.mkEnableOption "Enable IPC (needed for geth attach, etc)";
  };
in
{
  options.some.geth = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule extraGethOpts);
    default = { };
    description = "Whether to enable IPC interface (needed for `geth attach`, etc)";
  };
  config = {
    systemd.services = mapAttrs' unitForGeth eachGeth;
  };
}
