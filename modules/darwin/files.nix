{ ... }:

{
  # Files for Darwin go here
  imports = [ ../shared/files.nix ];

  # Examples:
  # xdg.configFile."nvim" = {
  #   source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/modules/shared/config/nvim";
  #   recursive = true;
  # }
  #
  # home.file.".config/lvim/config.lua" = {
  #   source = ./config/lvim/config.lua;
  # };
}
