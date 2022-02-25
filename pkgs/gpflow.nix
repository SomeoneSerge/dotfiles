{ lib
, python
, buildPythonPackage
, fetchFromGitHub
, tensorflow
, tensorflow-probability
, numpy
, scipy
, deprecated
, typing-extensions
, tabulate
, multipledispatch
, setuptools
, wheel
, build
, keras
, jupytext
, pytest
, nbconvert
}:
buildPythonPackage rec {
  pname = "GPflow";
  version = "2.3.1";
  src = fetchFromGitHub {
    owner = "GPflow";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-YOZ1S25VED6RVsylPv8Gh8iWoj0OIyPhn+KIK560HiU=";
  };
  buildInputs = [
    tensorflow
    tensorflow-probability
    jupytext
  ];
  propagatedBuildInputs = [
    keras
    numpy
    scipy
    deprecated
    typing-extensions
    tabulate
    multipledispatch
  ];
  nativeBuildInputs = [
    setuptools
    wheel
    build
  ];
  checkInputs = [
    pytest
    nbconvert
  ];
  postPatch = ''
    sed -i '/tensorflow>=/d' setup.py
  '';
  doCheck = true;
}
