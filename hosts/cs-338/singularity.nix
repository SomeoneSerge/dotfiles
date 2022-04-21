{ lib, config, pkgs, ... }:

let
  ldconfig = pkgs.writeScript "ldconfig" ''
    #! /usr/bin/env bash
    cleanup() {
      rm -f "$TMP"
    }
    trap cleanup EXIT

    TMP=$(mktemp)
    ldconfig -C "$TMP" /run/opengl-driver/lib
    ldconfig -C "$TMP" $@
  '';

  inherit (pkg) projectName;

  pkg = config.programs.singularity.package;
  pkgSuidBuild = pkg.override { withoutSuid = false; };
  pkgSuid = pkgSuidBuild.overrideAttrs (a: {
    postInstall = (a.postInstall or "") + ''
      sed -i 's|.*ldconfig path =.*|ldconfig path = ${ldconfig}|' $out/etc/${projectName}/${projectName}.conf
    '';
    installPhase = a.installPhase + ''
      [[ -f $out/libexec/${projectName}/bin/starter-suid ]]
      mv $out/libexec/${projectName}/bin/starter-suid $out/libexec/${projectName}/bin/starter-suid.orig
      ln -s /run/wrappers/bin/${projectName}-suid $out/libexec/${projectName}/bin/starter-suid
    '';
  });
in
{
  programs.singularity.enable = true;
  programs.singularity.package = pkgs.apptainer;
  programs.singularity.packageOverriden = lib.mkForce pkgSuid;
  security.wrappers."${pkg.projectName}-suid" = lib.mkForce
    {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgSuid}/libexec/${pkgSuid.projectName}/bin/starter-suid.orig";
    };
}


