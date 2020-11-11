{ config, pylinters, pythonPackages }:

{
  tsserver.enable = true;
  python.jediPath = "${pylinters}/lib/python3.8/site-packages/";
  python.linting.pydocstylePath = "${pylinters}/bin/pydocstyle";
  python.linting.mypyPath = "${pylinters}/bin/mypy";
  python.linting.pylintPath = "${pylinters}/bin/pylint";
  python.formatting.blackPath = "${pylinters}/bin/black";
  python.formatting.yapfPath = "${pylinters}/bin/yapf";
  python.sortImports.path = "${pylinters}/bin/isort";
  python.linting.flake8Path = "${pylinters}/bin/flake8";

  python.jediEnabled = true;
  python.linting.pydocstyleEnabled = true;
  python.linting.mypyEnabled = true;
  python.linting.flake8Enabled = true;

  json.format.enable = true;
  coc.preferences.formatOnSaveFiletypes = [
    "python"
    "json"
    "yaml"
  ];

  languageserver = {
    ccls = {
      "command"= "ccls";
      "filetypes"= [
        "c"
        "cpp"
        "cuda"
        "objc"
        "objcpp"
      ];
      "rootPatterns"= [
        ".ccls"
        "compile_commands.json"
        ".vim/"
        ".git/"
        ".hg/"
      ];
      "initializationOptions"= {
        "cache"= {
          "directory"= ".ccls-cache";
        };
      };
    };
    haskell = {
      "command"= "hie-wrapper";
      "args"= [
        "--lsp"
      ];
      "rootPatterns"= [
        "*.cabal"
        "stack.yaml"
        "cabal.project"
        "package.yaml"
      ];
      "filetypes"= [
        "hs"
        "lhs"
        "haskell"
      ];
      "initializationOptions"= {
        "languageServerHaskell"= {};
      };
    };
  };
}
