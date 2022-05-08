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
, jupytext
, matplotlib
}:
buildPythonPackage rec {
  pname = "GPflux";
  version = "0.2.7";
  src = fetchFromGitHub {
    owner = "secondmind-labs";
    repo = pname;
    rev = "744943768bc5ab79027adad9f04bd61a7b2d42a8";
    sha256 = "sha256-rrlx/D9S5ZjFUh8ltQYZv688GAkgFwq2lkPHi2b87+o=";
  };
  buildInputs = [
    tensorflow
    tensorflow-probability
    jupytext
  ];
  propagatedBuildInputs = [
    gpflow
    deprecated
    numpy
    scipy
  ];
  checkInputs = [
    pytest
    nbconvert
    matplotlib
  ];
  postPatch = ''
    # sed -i 's/tensorflow>/${builtins.replaceStrings ["-"] ["_"] tensorflow.pname}>/' setup.py
    sed -i '/tensorflow>/d' setup.py
  '';
}
