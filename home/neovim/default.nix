{ config, pkgs, lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  programs.neovim = {
    enable = mkDefault true;
    package = pkgs.neovim;

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

      " TODO: clean up this goddamn mess

      " Expand
      imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
      smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

      " Expand or jump
      imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
      smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

      " Jump forward or backward
      imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
      smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
      imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
      smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

      " Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
      " See https://github.com/hrsh7th/vim-vsnip/pull/50
      nmap        s   <Plug>(vsnip-select-text)
      xmap        s   <Plug>(vsnip-select-text)
      nmap        S   <Plug>(vsnip-cut-text)
      xmap        S   <Plug>(vsnip-cut-text)

      lua << EOF
        local opts = {
          log_level = 'info',
          auto_session_enable_last_session = false,
          auto_session_root_dir = "${config.xdg.dataHome}/auto-session/",
          auto_session_enabled = true,
          auto_save_enabled = true,
          auto_restore_enabled = true,
          auto_session_suppress_dirs =  {'~/', '~/Sources'}
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
      (
        pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "nvim-cmp";
          version = "2021-10-06";
          src = pkgs.fetchFromGitHub {
            owner = "hrsh7th";
            repo = "nvim-cmp";
            rev = "a39f72a4634e4bb05371a6674e3e9218cbfc6b20";
            sha256 = "04ksgg491nmyy7khdid9j45pv65yp7ksa0q7cr7gvqrh69v55daj";
          };
          meta.homepage = "https://github.com/hrsh7th/nvim-cmp/";
        }
      )
      (
        pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "cmp-nvim-lsp";
          version = "2021-09-30";
          src = pkgs.fetchFromGitHub {
            owner = "hrsh7th";
            repo = "cmp-nvim-lsp";
            rev = "f93a6cf9761b096ff2c28a4f0defe941a6ffffb5";
            sha256 = "02x4jp79lll4fm34x7rjkimlx32gfp2jd1kl6zjwszbfg8wziwmx";
          };
          meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp/";
        }
      )
      vim-vsnip
      nvim-treesitter
      fzf-vim
      gruvbox
      tabular
      # FIXME:
      fugitive
      vim-nix
      auto-session
    ];

    extraPackages = with pkgs; [
      elmPackages.elm-language-server
      elmPackages.elm-format
      elmPackages.elm-test # Workaround for https://github.com/elm-tooling/elm-language-server/issues/685
      elmPackages.elm # ...appears to be the easiest /facepalm
      texlab
      tree-sitter
      clang-tools
      cmake-language-server
      # (cmake-language-server.overrideAttrs (_: { doCheck = false; }))
      cpplint
      ccls
      haskell-language-server
      rust-analyzer
      clojure-lsp

      efm-langserver

      pyright
      black
      python3Packages.isort

      rnix-lsp
      nixpkgs-fmt
      yaml-language-server
      # nodePackages.typescript
      # nodePackages.typescript-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-langservers-extracted
      gopls
      luaformatter
      (
        let
          sumneko = sumneko-lua-language-server;
        in
        pkgs.writeScriptBin "sumneko_lua" ''
          ${sumneko}/bin/lua-language-server -E ${sumneko}/extras/main.lua $@
        ''
      )
    ];
    extraPython3Packages = ps:
      with ps; [
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
