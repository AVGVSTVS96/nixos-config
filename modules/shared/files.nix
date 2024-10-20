{ config, ... }:

{
  xdg.configFile = {
    "nvim" = {
      # mkOutOfStoreSymlink allows my nvim config to be symlinked directly from my nixos-config repo
      # This makes it's config files writeable, allowing nvim to pick up changes without rebuilding nix
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/modules/shared/config/nvim";
      recursive = true;
    };

    "lvim/config.lua" = {
      source = ./config/lvim/config.lua;
    };
  };
}
