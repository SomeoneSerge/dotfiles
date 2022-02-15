{ buildPythonPackage
, fetchFromGitHub
, tensorflow
, tensorflow-probability
, gpflux
, gpflow
, greenlet
, pytest
}:

buildPythonPackage rec {
  pname = "trieste";
  version = "0.9.1";
  src = fetchFromGitHub {
    owner = "secondmind-labs";
    repo = pname;
    rev = "a160d2400a2dc092cac599554d32217840c06e3d";
    sha256 = "sha256-5PJ3OL0LR9EDVLlIQTYhG8yZko9VaDfzuncP5Oc7TiE=";
  };
  postPatch = ''
    sed -i 's/gpflow==2.2.\\*/gpflow>=2.2/' setup.py
    sed -i '/tensorflow>=2.4/d' setup.py
  '';
  propagatedBuildInputs = [
    tensorflow
    tensorflow-probability
    gpflux
    gpflow
    greenlet
  ];
  checkInputs = [
    pytest
  ];
}
