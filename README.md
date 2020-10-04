# Someone's... dotfiles

A collection of cheap hacks to manage the dotfiles via [nix](https://nixos.org)
and [home-manager](https://github.com/nix-community/home-manager) on a
non-NixOS system.

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

Configurations for different hosts:

1. Laptop, wayland GUI
    ```bash
    nix build .#homeIntm
    ./result/activate # `homa-manager switch` equivalent
    ```

2. Devbox, headless, `allowUnfree=true`
    ```bash
    nix build .#homeAnarchy
    ./result/activate
    ```

Flakes should also allow fetch the artifact without explicitly cloning the repo:

```bash
nix build github:newkozlukov/dotfiles#homeIntm
```

This doesn't work at the time because the repo is private and `nix` apparently
uses github's HTTP api, unaware of ssh keys.
