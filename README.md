# Someone's... dotfiles

A collection of cheap hacks to manage the dotfiles via [nix](https://nixos.org)
and [home-manager](https://github.com/nix-community/home-manager) on a
**non-NixOS** system.

## Set-up

This repo manages, in a terribly ad hoc manner, the following hosts:
- "laptop"
    - Non-NixOS (archlinux)

    Just home-manager:
    `nix run .#home-laptop`

    - random wayland stuff
- "devbox"
    - Non-NixOS (archlinux)

    Just home-manager:
    `nix run .#home-devbox`

    - `nixpkgs.allowUnfree = true`
    - headless
- "ss-x230"
    - NixOS

    `sudo nixos-rebuild switch --flake .#`

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
    nix run .#home-laptop
    ```

    - No unfree packages
    - Has gui stuff

2. Devbox:
    ```bash
    nix run .#home-devbox
    ```

    - Unfree packages
    - No gui

---

## Side notes

- Flakes also allow fetching the artifact without explicitly cloning the repo:

  ```bash
  nix build github:newkozlukov/dotfiles#home-laptop
  ```
- The previous only works with public repos, because nix uses github's HTTP
  API, unaware of SSH keys
- Python language server configuration for neovim is currently very ad hoc and
  very limited.  It creates a `python -m` wrapper for each linter (like
  `black`, `jedi`, etc) that would run by fixed version of python in an
  isolated environment. This ensures that jedi&c doesn't crash (which it is
  very prone to), but also means that you'll still get `unable to import torch`
  messages from the linter.
