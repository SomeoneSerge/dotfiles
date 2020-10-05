# Someone's... dotfiles

A collection of cheap hacks to manage the dotfiles via [nix](https://nixos.org)
and [home-manager](https://github.com/nix-community/home-manager) on a
non-NixOS system.

## Set-up

This repo manages, in a terribly ad hoc manner, two hosts: call them a "laptop"
and "devbox". Both hosts are non-NixOS (archlinux and opensuse). Both host
configurations manage the same user, but usernames are different. Devbox is
allowed to install unfree software. The laptop is not. Laptop is being
gradually migrated to nix configuration. It runs wayland and a lot of
applications not managed by nix. Devbox is a headless non-nixos machine
with user environment mostly managed by nix.

## Prerequisites

Flakes-enabled `nix`:

1. [https://nixos.wiki/wiki/Nix_command](https://nixos.wiki/wiki/Nix_command)
2. Or just

   ```
   # /etc/nix/nix.conf
   experimental-features = nix-command flakes
   ```

   and `nix-env -iA nixUnstable -f '<nixpkgs>'`


## Usage

1. Laptop:
    ```bash
    nix build .#homeIntm
    ./result/activate # `homa-manager switch` equivalent
    ```

2. Devbox:
    ```bash
    nix build .#homeDevbox
    ./result/activate
    ```

---

## Side notes

- Flakes also allow fetching the artifact without explicitly cloning the repo:

  ```bash
  nix build github:newkozlukov/dotfiles#homeIntm
  ```
- The previous only works with public repos, because nix uses github's HTTP
  API, unaware of SSH keys
- Python language server configuration for neovim is currently very ad hoc and
  very limited.  It creates a `python -m` wrapper for each linter (like
  `black`, `jedi`, etc) that would run by fixed version of python in an
  isolated environment. This ensures that jedi&c doesn't crash (which it is
  very prone to), but also means that you'll still get `unable to import torch`
  messages from the linter.
