final: prev:

let pythonPackages = final.python3Packages;
in
{
  nix-visualize = pythonPackages.buildPythonPackage rec {
    name = "nix-visualize-${version}";
    version = "1.0.4";
    src = prev.fetchFromGitHub {
      owner = "craigmbooth";
      repo = "nix-visualize";
      rev = "ee6ad3cb3ea31bd0e9fa276f8c0840e9025c321a";
      sha256 = "sha256-nsD5U70Ue30209t4fU8iMLCHzNZo18wKFutaFp55FOw=";
    };
    propagatedBuildInputs = with pythonPackages; [
      matplotlib
      networkx
      pygraphviz
    ];
  };
}
