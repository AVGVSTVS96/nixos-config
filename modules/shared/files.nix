{ pkgs, config, ... }:

{
  ".config/lvim/config.lua" = {
    source = ./config/lvim/config.lua;
  };

  # Initializes Emacs with org-mode so we can tangle the main config
  # ".emacs.d/init.el" = {
  #   text = builtins.readFile ../shared/config/emacs/init.el;
  # };
  
  # Symlink the Tokyo Night theme for Yazi into the correct directory
  #   ".config/yazi/flavors/tokyo-night.yazi" = {
  #     source = pkgs.fetchFromGitHub {
  #       owner = "BennyOe";
  #       repo = "tokyo-night.yazi";
  #       rev = "main"; # Consider using a specific commit hash for stability
  #       sha256 = "112r9b7gan3y4shm0dfgbbgnxasi7ywlbk1pksdbpaglkczv0412";
  #     };
  #     recursive = true;
  #   };
  # config.lua fiole for lvim config written in nix 
}
