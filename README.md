# Some dotfiles

Almost all hosts are running [NixOS](https://nixos.org)
and using [home-manager](https://github.com/nix-community/home-manager)
for refining user's environments.
In their case I check out this repo at `/etc/nixos`, after which
`nixos-rebuild` can be used as usual: it will detect the flake.nix, so the
pinned dependencies will be used, and composed appropriately.
In case of non-NixOS hosts I'm provisioning only the home environment part.
I do so by directly calling the home-manager and exposing its activation script as a flake app,
which can be used e.g. as `nix run .#home-devbox`.

## Neovim

Neovim is configured in [./home/neovim/](./home/neovim/default.nix) via the
home-manager.

Since recently, I'm using [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
instead of [coc.nvim](https://github.com/neoclide/coc.nvim), which I'm pretty happy about.
The nvim-lspconfig requires `nvim-0.5` or higher, which is not yet available in nixpkgs stable,
so I'm substituting the newer `nvim-0.6` from the upstream directly in the `flake.nix`
when importing `nixpkgs` (see `neovimOverlay`).
The rest is making a bunch of language servers visible to the neovim via `extraPackages` and `extraPython3Packages`
and copy-pasting lsp configuration in lua from appropriate github-readmes.

I'm using [auto-session](https://github.com/rmagatti/auto-session) instead of Obsession

I couldn't get clangd to work properly, but ccls appears to quite satisfy my needs.

For some reason rnix's formatting behaves differently than nixpkgs-fmt called from the shell.

## Pinned registry

I pin the registry and copy its contents into the `NIX_PATH` directly in the
`flake.nix`, cf. "`pin-registry`". This allows me to conveniently use the
less-verbose pre-flakes nix tools (like nix-repl and nix-shell) without
accidentally pulling down a random nixpkgs version (behaviour typical to the
legacy nix-channels)
