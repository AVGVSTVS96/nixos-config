# NixOS & macOS Configuration

> [!NOTE]
> Personal NixOS/macOS config using flakes. Forked from [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config) with significant structural changes.

> [!WARNING]
> Contains encrypted secrets and personal hardware configs. Use as reference, not direct clone.

## Quick Start

```bash
# After initial installation (see Installation section below)
cd ~/nixos-config

# Add packages: edit modules/shared/packages.nix
# Then rebuild:
nix run .#build-switch

# Shell alias for convenience:
ns  # Same as: git add . && nix run .#build-switch
```

## Daily Workflows

### Updating Packages

```bash
cd ~/nixos-config

# Update specific input (recommended for package updates)
nix flake update nixpkgs

# Or update everything (nixpkgs, home-manager, all inputs)
nix flake update

# Rebuild to apply updates
nix run .#build-switch  # or: ns
```

**What happens**: `nix flake update` updates `flake.lock` with latest package versions from `nixos-unstable`.

### Testing Changes

```bash
# Build without activating (test for errors)
nix run .#build  # or: nb

# If successful, activate
nix run .#build-switch  # or: ns
```

### Rollback

```bash
# macOS only
nix run .#rollback

# NixOS: use generation menu at boot
```

## Common Tasks

### Adding Packages

Edit the appropriate file based on where you want the package:

```bash
# All systems
nvim modules/shared/packages.nix

# macOS only
nvim modules/darwin/packages.nix

# NixOS only
nvim modules/nixos/packages.nix

# Then rebuild
nix run .#build-switch
```

### Switching Shells

Edit your host configuration in `hosts/<hostname>/default.nix`:

```nix
shells.fish.enable = true;   # or false
shells.zsh.enable = false;   # or true
```

### Managing Secrets

Secrets use `ragenix` (agenix Rust rewrite):

```bash
# Generate keys (first time only)
nix run .#create-keys

# Edit a secret
nix run github:yaxitech/ragenix -- -e secrets/mysecret.age

# Secrets are defined in modules/shared/secrets.nix
```

**Note**: This repo's encrypted secrets won't work for you - generate your own.

## Configuration Structure

```
.
├── apps/         # Build commands (apply, build, build-switch, etc.)
├── hosts/        # Host-specific configs (nixos, darwin, vm)
├── modules/
│   ├── darwin/   # macOS-specific
│   ├── nixos/    # NixOS-specific  
│   └── shared/   # Shared between platforms
│       ├── packages.nix  # Package declarations
│       ├── programs.nix  # Program configurations
│       ├── files.nix     # Home file management
│       └── config/       # Config files (fish, tmux, etc.)
├── secrets/      # Encrypted secrets (agenix)
└── flake.nix     # Main entry point
```

### Where to Edit

- **Add packages**: `modules/{shared,darwin,nixos}/packages.nix`
- **Configure programs**: `modules/shared/programs.nix`
- **Program-specific configs**: `modules/shared/config/<program>/`
- **Host settings**: `hosts/<hostname>/default.nix`
- **Secrets**: `modules/shared/secrets.nix`

## Key Features

- **100% Flakes**: No channels, pure flake inputs
- **Multi-shell**: Fish/Zsh toggle via simple option
- **Secrets**: Encrypted with ragenix (faster agenix rewrite)
- **Auto-sync repos**: neovim-config and TPM auto-pull on rebuild
- **Modular**: Shared configs with platform overrides

## Installation

### macOS

```bash
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Clone & setup
git clone https://github.com/AVGVSTVS96/nixos-config.git ~/nixos-config
cd ~/nixos-config
nix run .#apply  # Configure user info

# 3. Generate keys
nix run .#create-keys

# 4. Build
nix run .#build-switch
```

### NixOS

```bash
# From NixOS installer
sudo nix run --extra-experimental-features 'nix-command flakes' \
  github:AVGVSTVS96/nixos-config#install

# Follow prompts for hostname, disk selection, etc.
# Set password after first boot: passwd <username>
```

**Important**: Installation scripts detect network interfaces and disk config automatically. Review `hosts/nixos/default.nix` and `modules/nixos/disk-config.nix` if you have custom networking or disk setups.

## Acknowledgments

Inspired by excellent configs from the Nix community:
- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- [More favorites →](https://github.com/stars/AVGVSTVS96/lists/my-favorite-nix-configs)

## License

BSD 3-Clause - See [LICENSE](LICENSE)

