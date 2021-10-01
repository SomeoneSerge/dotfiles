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
        local opts = {
          log_level = 'info',
          auto_session_enable_last_session = true,
          auto_session_root_dir = "/home/ss/.local/share/auto-session",
          auto_session_enabled = true,
          auto_save_enabled = true,
          auto_restore_enabled = true,
          auto_session_suppress_dirs = nil
        }
        require('auto-session').setup(opts)
      EOF

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
      auto-session
    ];

    extraPackages = with pkgs; [
      texlab
      tree-sitter
      clang-tools
      cmake-language-server
      cpplint
      ccls
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
      nodePackages.bash-language-server
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
