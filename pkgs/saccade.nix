{ stdenv
, fetchFromGitHub
, cmake
, freeimage
, gflags
, glog
, mesa
, freeglut
, qtbase
, qt3d
, python3
, mesa_glu
, libglvnd
, wrapQtAppsHook
}: stdenv.mkDerivation rec {
  pname = "saccade";
  version = "0";
  src = fetchFromGitHub {
    owner = "PatWie";
    repo = pname;
    rev = "e1b6699db246fae5ad0ad8f7fafb816a2a02b2f7";
    sha256 = "sha256-8Objcgsm/y9dWtSLJ9WSC4/Wl48LBPwoUbFljjsFWbo=";
  };
  nativeBuildInputs = [ cmake wrapQtAppsHook ];
  buildInputs = [ freeimage gflags glog mesa.dev freeglut.dev mesa_glu.dev libglvnd qt3d qtbase python3 ];
  cmakeFlags = [
    "-DOpenGL_GL_PREFERENCE=GLVND"
    "-DCMAKE_CXX_FLAGS=-Wl,-lGL"
  ];
  installPhase = ''
    mkdir -p $out/bin
    install saccade -t $out/bin -m0555
  '';
}
