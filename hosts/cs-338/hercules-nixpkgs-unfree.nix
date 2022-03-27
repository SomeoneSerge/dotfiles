{ config, pkgs, inputs, ... }:

let container = {
  autoStart = true;
  ephemeral = true;
  bindMounts."/var/lib/hercules-ci-agent" = {
    hostPath = "/var/lib/hercules-nixpkgs-unfree";
    isReadOnly = false;
  };
  config = {
    imports = [
      inputs.hercules-ci-agent.nixosModules.agent-service
    ];

    services.hercules-ci-agent.enable = true;
    services.hercules-ci-agent.settings.concurrentTasks = 32;
  };
};
in
{
  containers.hercules-nixpkgs-unfree = container;
}
