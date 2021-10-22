final: prev:

let
  pkg =
    { lib
    , buildPythonPackage
    , fetchPypi
    , pythonOlder
    , setuptools-scm
    , importlib-metadata
    , packaging
      # Check Inputs
    , pytestCheckHook
    , numpy
    , matplotlib
    , uncertainties
    }: buildPythonPackage rec {
      pname = "pint";
      version = "0.17";

      src = fetchPypi {
        inherit version;
        pname = "Pint";
        sha256 = "sha256-9NDKpxMjnmhHp8bu/iQnNYVmRR/lZJfVM/IftZCj8xM=";
      };

      doCheck = false;

      nativeBuildInputs = [ setuptools-scm ];

      propagatedBuildInputs = [ packaging ]
        ++ lib.optionals (pythonOlder "3.8") [ importlib-metadata ];

      # Test suite explicitly requires pytest
      checkInputs = [
        pytestCheckHook
        numpy
        matplotlib
        uncertainties
      ];
      dontUseSetuptoolsCheck = true;

    };
in
{
  pint = final.python3Packages.callPackage pkg { };
}
