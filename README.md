# NixOS and macOS Configuration

> [!NOTE]
> This config started as a fork of [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config), with some significant changes in structure, improvements in modularity, and customizations to fit my personal workflow. This readme was written with the help of Claude AI, inspired by the original but adapted and expanded upon.

> [!WARNING]
> This is a personal configuration that contains encrypted secrets and specific hardware configurations. While you're welcome to use it as inspiration, you'll need to adapt it to your own needs, generate your own secrets, and possibly adjust network and hardware settings for your environment.

## Overview

This repository contains a modular, declarative configuration for managing both NixOS and macOS environments. It uses Nix Flakes to provide reproducible builds and a consistent environment across different machines.

## Features

- **100% Flake-driven**: No confusing channels, just clean `flake.nix` configuration
- **Multiple Shell Support**: Easily switch between Fish and Zsh with a single option
- **Secrets Management**: Encrypted secrets with `agenix` for SSH keys, API tokens, and more
- **Custom Modules**: Modular organization with shared components across platforms
- **Self-documenting**: Extensive comments and README files throughout the codebase
- **Development Workflow**: Modern tooling like helix, neovim, lunarvim, and more
- **User-friendly**: Simplified commands for building, switching, and updating
- **Ragenix**: Using the enhanced Rust implementation of agenix for better performance

## Key Features and Customizations

### Custom Shell Framework

One of the main customizations in this configuration is the modular shell system that allows easily switching between Fish and Zsh shells. The implementation is in:

- **`modules/shared/shells/zsh.nix`**: Zsh shell configuration
- **`modules/shared/shells/fish.nix`**: Fish shell configuration
- **`modules/shared/options.nix`**: Defines the custom `shells.activeShell` option

This allows configuration like:

```nix
# Enable shell in your host configuration
shells.zsh.enable = true;
shells.fish.enable = false;

# Then in programs modules, use conditionals:
programs.fzf = {
  enable = true;
  enableZshIntegration = isZsh;
  enableFishIntegration = isFish;
};
```

### Enhanced Terminal Experience

The configuration sets up a rich terminal environment with:

1. **Multiple Terminal Emulators**: 
   - **Alacritty**: Configured in `modules/shared/programs.nix` with custom opacity and colors
   - **WezTerm**: Configured in `modules/shared/programs.nix` with Tokyo Night theme, tab customizations, and performance optimizations

2. **Modern CLI Tools**:
   - **eza**: Modern ls replacement with git integration
   - **bat**: Better cat with syntax highlighting
   - **fd**: Friendly alternative to find
   - **fzf**: Fuzzy finder with custom previews
   - **zoxide**: Smarter cd command
   - **yazi**: Terminal file manager
   - **tmux**: Terminal multiplexer with custom key bindings

3. **Editors**:
    - **Helix**: Batteries included vim/neovim alternative
    - **Neovim**: Symlinked from separate neovim config repo in `~/neovim-config/`
    - **LunarVim**: Backup editor, configured in `./modules/shared/config/lvim/`

### Tokyo Night Theme Integration

The configuration uses Tokyo Night theme across multiple applications:

1. **Terminal**: Custom Tokyo Night colors for Alacritty and native theme for WezTerm
2. **Editors**: Tokyo Night for Helix, Vim, and LunarVim
3. **Theme Module**: Uses the `tokyonight.nix` module for consistent theming

### Advanced Git Workflow

Git is configured with:

1. **Enhanced Diff**: Using delta for improved diffs (theme currently not working!)
2. **Lazygit**: Terminal UI for git
3. **Graphite CLI**: Integration with custom aliases in `modules/shared/config/graphite/aliases`
4. **Signing**: Automatic commit signing with SSH keys

### Secret Management with Ragenix

The configuration uses Ragenix (Rust implementation of agenix) for managing secrets:

1. **API Keys**: Anthropic, OpenAI
2. **Email**: Gmail configuration
3. **SSH Keys**: Primary SSH key
4. **Graphite Configuration**: Encrypted Graphite credentials

## Repository Structure

```
.
├── apps/         # Platform-specific commands for bootstrapping and building
├── hosts/        # Host-specific configuration (nixos, vm, darwin)
├── modules/      # Configuration modules shared across platforms
│   ├── darwin/   # macOS-specific configuration
│   ├── nixos/    # NixOS-specific configuration
│   └── shared/   # Configuration shared between platforms
├── overlays/     # Nix overlays for patching or modifying packages
├── secrets/      # Encrypted secrets managed by agenix
└── flake.nix     # The main entry point for the configuration
```

## Installation

> [!CAUTION]
> Some scripts in this repository are works in progress or may need adaptation for your specific hardware. Pay special attention to network interface setup, disk configuration, and host-specific settings.

### Installation Process Scripts

To better understand how installation works, here's an overview of the key scripts involved:

#### Darwin (macOS) Installation Scripts

- **`apps/aarch64-darwin/apply`**: Gathers user information, detects system details, and replaces placeholders in config files
- **`apps/aarch64-darwin/build`**: Builds the configuration without activating it
- **`apps/aarch64-darwin/build-switch`**: Builds and activates the new configuration
- **`apps/aarch64-darwin/create-keys`**: Generates SSH keys for GitHub and agenix
- **`apps/aarch64-darwin/copy-keys`**: Attempts to copy keys from a USB drive (needs attention)
- **`apps/aarch64-darwin/check-keys`**: Verifies that required keys are in place
- **`apps/aarch64-darwin/rollback`**: Allows rolling back to a previous generation

#### NixOS Installation Scripts

- **`apps/x86_64-linux/apply`**: Similar to the Darwin version, prepares the configuration with user info
- **`apps/x86_64-linux/build-switch`**: Builds and activates the configuration
- **`apps/x86_64-linux/install`**: Main installation script that:
  1. Checks the installer environment
  2. Detects architecture
  3. Prompts for host selection
  4. Detects network interfaces
  5. Selects boot disk
  6. Clones the repository
  7. Replaces tokens in configuration
  8. Runs disko for disk configuration
  9. Sets up configuration files
  10. Installs NixOS
  11. Prompts for reboot

The installation flow generally follows:
1. Run apply script to customize configuration
2. Set up keys for secrets (create or copy)
3. Run build or build-switch to activate the configuration

Each script is designed to be run at specific points in the setup process, with install scripts handling the initial setup and build/apply scripts for subsequent modifications.

### For macOS

```sh
# 1. Install dependencies
xcode-select --install

# 2. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 3. Clone this repository
git clone https://github.com/YOUR_USERNAME/nixos-config.git
cd nixos-config

# 4. Make apps executable
find apps/$(uname -m | sed 's/arm64/aarch64/')-darwin -type f -name "apply" -o -name "build" -o -name "build-switch" -o -name "create-keys" -o -name "copy-keys" -o -name "check-keys" -exec chmod +x {} \;

# 5. Apply your user info
nix run .#apply
# This will prompt for your information and replace placeholders in the configuration

# 6. Set up secrets (required for full functionality)
nix run .#create-keys
# Creates SSH keys for GitHub and agenix in ~/.ssh/
# You'll need to create your own secrets with agenix after this

# 7. Build and switch to the configuration
nix run .#build-switch
```

### For NixOS

```sh
# 1. Boot from the NixOS installer

# 2. Network configuration happens during the install script
# The script will detect your primary network interface automatically
# You may need to modify modules/nixos/disk-config.nix for your disk layout

# 3. Install configuration
sudo nix run --extra-experimental-features 'nix-command flakes' github:YOUR_USERNAME/nixos-config#install
# You'll be prompted for hostname, disk selection, and other information

# 4. Set user password on first boot
# Ctrl-Alt-F2, login as root, run: passwd YOUR_USERNAME
```

### Important Notes About Network Configuration

Several scripts handle network interface detection:

1. **`apps/x86_64-linux/apply`** and **`apps/aarch64-darwin/apply`**: These scripts run during the initial setup and detect your primary network interface using:
   ```sh
   export PRIMARY_IFACE=$(ip -o -4 route show to default | awk '{print $5}')
   ```

2. **`apps/x86_64-linux/install`**: This installation script also performs network detection as part of the NixOS installation process, using the same method.

These scripts replace `%INTERFACE%` placeholders in configuration files like `hosts/nixos/default.nix` and `hosts/vm/default.nix` with your detected network interface. You may need to manually adjust these files if:

1. You have multiple network interfaces
2. Your network setup changes frequently
3. You're using special networking features (VLANs, bridges, etc.)

The network configuration itself is defined in the host configuration files:
```nix
# Example from hosts/nixos/default.nix
networking = {
  inherit hostName;
  useDHCP = false;
  interfaces."%INTERFACE%".useDHCP = true;
};
```

### Secrets Management

Secrets are managed with `agenix` and stored in the `secrets/` directory. **Note that the encrypted secrets in this repository are personal** and will not work for you. You'll need to:

1. Generate your own SSH keys with `nix run .#create-keys`
2. Create a new `secrets.nix` file with your public keys
3. Create your own encrypted secrets with `agenix`

```nix
# Example of how secrets are defined in modules/shared/secrets.nix
age.secrets = {
  primary = {
    file = ../../secrets/primary.age;
    owner = userName;
    mode = "600";
  };
  
  # API keys
  anthropic = {
    file = ../../secrets/anthropic.age;
    owner = userName;
    mode = "600";
  };
  
  # ... other secrets
};
```

To create your own secrets:

```sh
# Create a secrets.nix file (example structure in secrets/secrets.nix)
# Then create encrypted secrets with:
nix run github:ryantm/agenix -- -e secret.age

# After creating your secrets, add them to modules/shared/secrets.nix
```

## Daily Usage

The configuration includes several convenient command shortcuts both as Nix run commands and shell aliases:

```sh
# Update configuration after changes
nix run .#build-switch
# Or use the shell alias:
# ns (git add . && nix run .#build-switch)

# Build without switching (testing)
nix run .#build
# Or use the shell alias:
# nb (git add . && nix run .#build)

# Rollback to a previous generation (macOS)
nix run .#rollback

# Other useful shell aliases included:
# g - git
# lg - lazygit
# yz - yazi (terminal file manager)
# ls/lsa/l/la - enhanced eza listings with git status
# lt/lt2/lt3 - tree view with different depth levels
```

### Adding New Packages

For quick package addition, edit the appropriate files:

```sh
# For packages on all systems
nvim modules/shared/packages.nix

# For macOS-specific packages
nvim modules/darwin/packages.nix

# For NixOS-specific packages
nvim modules/nixos/packages.nix
```

## Customization

The configuration is designed to be easily customizable:

1. **Host-specific settings**: Add or modify host directories in the `hosts/` folder
2. **Shared components**: Edit files in the `modules/shared/` directory
3. **Platform-specific settings**: Modify files in `modules/darwin/` or `modules/nixos/`
4. **Overlays**: Add custom package modifications to the `overlays/` directory

### Known Incomplete Areas

This configuration is a work in progress, and some areas that may need special attention include:

1. **Secret Management Scripts**: The `copy-keys` script (in `apps/aarch64-darwin/copy-keys`) has some incomplete sections and may need updates for your workflow.

2. **Network Configuration**: Network interface detection happens in the `apply` script, but you might need to modify this for complex network setups.

3. **Disk Configuration**: The disk setup in `modules/nixos/disk-config.nix` uses a placeholder for the disk name that gets replaced during installation. Verify this works with your hardware.

4. **VM Support**: The VM configuration is designed for specific virtualization environments and may need adjustments for your setup.

5. **Graphics Drivers**: The NixOS configuration includes commented sections for AMD and NVIDIA GPUs that you'll need to uncomment and adjust based on your hardware.

## Acknowledgments

This configuration wouldn't be possible without the work of many talented Nix community members, some of my favorite configs include:

- **[dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)**
- **[ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)**
- **[Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)**
- **[mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)**
- **[oddlama/nix-config](https://github.com/oddlama/nix-config)**
- **[wimpysworld/nix-config](https://github.com/wimpysworld/nix-config)**
- **[hgl/configs](https://github.com/hgl/configs)**

Special thanks to them and the broader Nix community. See more of my favorite configs [here](https://github.com/stars/AVGVSTVS96/lists/my-favorite-nix-configs)!

## License

BSD 3-Clause License (see [LICENSE](LICENSE) file for details)

