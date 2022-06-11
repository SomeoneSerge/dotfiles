{ requireFile
, stdenv
, dpkg
, rsync
, autoPatchelfHook
, alsa-lib
, nss
, xorg
, udev
, gtk3
}:

let
in
stdenv.mkDerivation {
  pname = "nvidia-sdk-manager";
  version = "1.8.0";

  src = requireFile {
    message = ''
      Download sdkmanager_1.8.0-10363_amd64.deb manually and add it to the store.
      NVidia behaves like a no-name aliexpress seller and ships hardware without usable software,
      but additionally forces you to fill in thousands of webforms with your personal data.
    '';
    name = "sdkmanager_1.8.0-10363_amd64.deb";
    sha256 = "sha256-Oa3x2d5cNnqIiENGWtjIlkWt/sAqsGl7ogxvvclpnfk=";
  };

  nativeBuildInputs = [
    dpkg
    rsync
    autoPatchelfHook
  ];

  # for autoPatchelf
  buildInputs = [
    xorg.libX11
    xorg.libXi
    xorg.libXrender
    xorg.libXcursor
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libXdamage
    nss
    alsa-lib
    gtk3
    udev
    stdenv.cc.cc
  ];

  dontBuild = true;

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir $out
    rsync opt/ $out/opt/ -a
    rsync usr/ $out/usr/ -a
  '';

  installCheckPhase = ''
  '';
}
