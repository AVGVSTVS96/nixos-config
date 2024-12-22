{ config, ... }:
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
  };
}
