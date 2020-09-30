self: super: {
  pylinters = let 
    python = super.python3.withPackages (ps: with ps; [
      pylint
      black
      flake8
      isort
      pydocstyle
      mypy
      jedi
      yapf
    ]);
  in super.stdenv.mkDerivation {
    name = "pylinters-env";
    nativeBuildInputs = [
      super.makeWrapper
    ];
    buildInputs = [
      super.makeWrapper
      python
    ];
    phases = [ "buildPhase" ];
    buildPhase = ''
      . "${super.makeWrapper}/nix-support/setup-hook"
      mkdir -p $out/bin
      for prog in jedi pylint mypy flake8 pydocstyle black isort yapf ; do
        makeWrapper ${python}/bin/python $out/bin/$prog --argv0 $prog --add-flags "-m $prog"
      done
    '';
  };
}
