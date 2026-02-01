{ config, pkgs, ... }:
let
  inherit (config.home) homeDirectory;
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dotfiles = "${homeDirectory}/nixos-config/modules/shared/config";
in
{
  xdg.configFile = {
    # mkOutOfStoreSymlink symlinks directly from the source, instead of the nix store
    # This allows the files to be writeable, allowing changes to be made without rebuilding nix
    "nvim" = { 
      source = mkOutOfStoreSymlink "${homeDirectory}/neovim-config";
      recursive = true;
    }; 

    "lvim/config.lua" = {
      source = mkOutOfStoreSymlink "${dotfiles}/lvim/config.lua";
    };

    "graphite/aliases" = {
      source = mkOutOfStoreSymlink "${dotfiles}/graphite/aliases";
    };

    "oh-my-posh/tokyonight_storm-customized.omp.json" = {
      source = mkOutOfStoreSymlink "${dotfiles}/oh-my-posh/tokyonight_storm-customized.omp.json";
    };

    "fish/functions" = {
      source = mkOutOfStoreSymlink "${dotfiles}/fish/functions";
      recursive = true;
    };

    "tmux" = {
      source = mkOutOfStoreSymlink "${dotfiles}/tmux";
      recursive = true;
    };
  };

  home.file = {
    ".local/bin/omp-monorepo" = {
      source = mkOutOfStoreSymlink "${dotfiles}/oh-my-posh/omp-monorepo";
    };

    "commit.sh" = {
      source = mkOutOfStoreSymlink "${dotfiles}/fish/commit.sh";
    };
  };

  # Clone/update TPM (Tmux Plugin Manager)
  home.activation.syncTpm = config.lib.dag.entryAfter ["writeBoundary"] ''
    TPM_DIR="$HOME/.local/share/tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR" ]; then
      mkdir -p "$HOME/.local/share/tmux/plugins"
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
      echo "✓ TPM cloned to $TPM_DIR"
    else
      # Ensure remote uses HTTPS
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$TPM_DIR" remote set-url origin https://github.com/tmux-plugins/tpm
      PULL_OUTPUT=$(${pkgs.git}/bin/git -C "$TPM_DIR" pull 2>&1)
      if echo "$PULL_OUTPUT" | grep -q "Already up to date"; then
        echo "✓ TPM already up to date"
      else
        echo "✓ TPM updated"
        echo "$PULL_OUTPUT" | grep -E "Fast-forward|Updating" || true
      fi
    fi
  '';

  # Clone/update neovim config repo (use HTTPS to avoid SSH issues)
  home.activation.syncNeovimConfig = config.lib.dag.entryAfter ["writeBoundary"] ''
    NVIM_CONFIG_DIR="$HOME/neovim-config"
    if [ ! -d "$NVIM_CONFIG_DIR" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/AVGVSTVS96/neovim-config.git "$NVIM_CONFIG_DIR"
      echo "✓ Neovim config cloned to $NVIM_CONFIG_DIR"
    else
      # Ensure remote uses HTTPS (convert SSH to HTTPS if needed)
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$NVIM_CONFIG_DIR" remote set-url origin https://github.com/AVGVSTVS96/neovim-config.git
      PULL_OUTPUT=$(${pkgs.git}/bin/git -C "$NVIM_CONFIG_DIR" pull 2>&1)
      if echo "$PULL_OUTPUT" | grep -q "Already up to date"; then
        echo "✓ Neovim config already up to date"
      else
        echo "✓ Neovim config updated"
        echo "$PULL_OUTPUT" | grep -E "Fast-forward|Updating" || true
      fi
    fi
  '';
}
