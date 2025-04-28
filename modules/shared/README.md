## Shared
Much of the code running on MacOS or NixOS is actually found here.

This configuration gets imported by both modules. Some configuration examples include `git`, `zsh`, `vim`, and `tmux`.

## Layout
```
.
├── config/            # Config files not written in Nix
├── shells/            # System and user shell configuration
├── cachix/            # Defines cachix, a global cache for builds
├── default.nix        # Imports all shared modules, imported by hosts
├── nix.nix            # Shared Nix configuration
├── options.nix        # Custom config options, like choosing a shell
├── secrets.nix        # Agenix secrets configuration
├── files.nix          # Symlinks for non-nix config files
├── programs.nix       # Shared user config, imported by OS-specific home-manager modules
├── packages.nix       # Shared system and user packages
└── README.md          # This file

```
