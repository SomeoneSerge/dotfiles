{ buildPythonPackage
, fetchFromGitHub
, matplotlib
}:

let
  pname = "tol-colors";
  version = "1.2.1";
in
buildPythonPackage {
  inherit pname version;

  propagatedBuildInputs = [ matplotlib ];
  src = fetchFromGitHub {
    owner = "Descanonge";
    repo = "tol_colors";
    rev = "v${version}";
    hash = "sha256-oA9L3HBjZt+kmhxTa5r0wpMtwYneAl+LubbsIRFkLeM=";
  };
}
