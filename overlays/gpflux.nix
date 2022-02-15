{ lib
, buildPythonPackage
, fetchFromGitHub
, tensorflow
, tensorflow-probability
, deprecated
, numpy
, scipy
, gpflow
, pytest
, nbconvert
}:
buildPythonPackage rec {
  pname = "GPflux";
  version = "0.2.7";
  src = fetchFromGitHub {
    owner = "secondmind-labs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ZmqI9dm8IBCmsEqRKVyZdhfxz/mxH5ZDJEfSMidl4yM=";
  };
  propagatedBuildInputs = [
    gpflow
    tensorflow
    tensorflow-probability
    deprecated
    numpy
    scipy
  ];
  checkInputs = [
    pytest
    nbconvert
  ];
  postPatch = ''
    sed -i '/tensorflow-probability/d' setup.py
    sed -i '/tensorflow>/d' setup.py
  '';
}
