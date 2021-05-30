final: prev: {
  pylinters = let
    python = prev.python3.withPackages (ps:
      with ps; [
        pylint
        black
        flake8
        autopep8
        isort
        pydocstyle
        mypy
        jedi
        yapf
      ]);
    wrappers = prev.stdenv.mkDerivation {
      name = "pylinters";
      nativeBuildInputs = [ prev.makeWrapper ];
      buildInputs = [ prev.makeWrapper python ];
      phases = [ "buildPhase" ];
      buildPhase = ''
        . "${prev.makeWrapper}/nix-support/setup-hook"
        mkdir -p $out/bin
        for prog in jedi ; do
          makeWrapper ${python}/bin/python $out/bin/$prog --argv0 $prog --add-flags "-m $prog"
        done
      '';
    };
  in prev.buildEnv {
    name = "pylinters-env";
    paths = [ python wrappers ];
  };
}
