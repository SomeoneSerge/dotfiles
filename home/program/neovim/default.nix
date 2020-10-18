{ config, lib, pkgs, ... }:

let
  pyPkgs = (ps: with ps; [
    # Currently useless, because
    # https://github.com/NixOS/nixpkgs/issues/98166
    pkgs.pylinters
    ]);
  cocConfigDict = import ./coc.nix { config = config; pylinters = pkgs.pylinters; };
  cocConfig = (pkgs.writeText "coc-settings.json" (builtins.toJSON cocConfigDict));
in
{
  programs.neovim = {
    enable = true;
    vimAlias = true;

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

    ''
    + (builtins.readFile ./coc.vim);

    # Neovim plugins
    plugins = with pkgs.vimPlugins; [
      fzf-vim
      ctrlp
      editorconfig-vim
      gruvbox
      tabular
      vim-nix
      fugitive
      coc-nvim
      coc-yaml
      coc-json
      coc-python
    ];

    withPython = false;
    withPython3 = true;
    extraPython3Packages = pyPkgs;
  };

  # xdg.configFile."nvim/coc-settings.json".text = ''
  #   {
  #     "python.linting.pylintPath": "nix-shell -p 'python3.withPackages(ps: [ps.pylint])' --run 'python -m pylint'"
  #   }
  # '';
  xdg.configFile."nvim/coc-settings.json".source = cocConfig;
}
