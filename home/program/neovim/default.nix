{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;

    package = pkgs.neovim-nightly;

    extraConfig = ''
      :imap jk <Esc>
      :set number
      :set expandtab
      :set tabstop=4
      :set shiftwidth=4
      :set numberwidth=4
      :set updatetime=300

      " Disable F1
      :nmap <F1> :echo<CR>
      :imap <F1> <C-o>:echo<CR>

      " Fzf config borrowed from @newzubakhin
      noremap <Leader>b :Buffers<CR>
      noremap <Leader>h :History<CR>
      noremap <Leader>s :Ag<CR>
      noremap <Leader>f :Files<CR>

      lua << EOF
      ${lib.strings.fileContents ./lsp.lua}
      EOF
    '';

    # Neovim plugins
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-compe
      nvim-treesitter
      fzf-vim
      gruvbox
      tabular
      # FIXME:
      # fugitive
      vim-nix
    ];

    extraPackages = with pkgs; [
      tree-sitter
      clang-tools
      cmake-language-server
      cpplint
      haskell-language-server
      rust-analyzer
      pyright
      python3Packages.python-language-server
      black
      rnix-lsp
      nixpkgs-fmt
      yaml-language-server
      nodePackages.typescript
      nodePackages.typescript-language-server
      gopls
      sumneko-lua-language-server
      luaformatter
      (
        let sumneko = sumneko-lua-language-server;
        in
        pkgs.writeScriptBin "sumneko_lua" ''
          ${sumneko}/bin/lua-language-server -E ${sumneko}/extras/main.lua $@
        ''
      )
    ];
    extraPython3Packages = ps:
      with ps; [
        pyls-black
        pyls-isort
        pyls-mypy
        pylint
        black
        flake8
        isort
        pydocstyle
        mypy
        yapf
      ];
    withPython3 = true;
  };
}
