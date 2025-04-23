{ variables, inputs, config, lib, ... }:
let
  inherit (variables) userName;
  inherit (inputs) homebrew-bundle homebrew-core homebrew-cask;
  inherit (lib) mkIf mkEnableOption;
  cfg = config.nix-homebrew;
in
{
  options = {
    # Homebrew shell integration, may be merged into nix-homebrew
    # https://github.com/zhaofengli/nix-homebrew/pull/39
    #
    # TODO: PR merged, update and test using nix-darwin interactiveShellInit
    # instead of home-manager shell config like in PR
    #
    # nix-homebrew = {
    #   enableZshIntegration = mkEnableOption "homebrew zsh integration" // {
    #     default = false;
    #   };
    #   enableBashIntegration = mkEnableOption "homebrew bash integration" // {
    #     default = false;
    #   };
    #   enableFishIntegration = mkEnableOption "homebrew fish integration" // {
    #     default = false;
    #   };
    #   enableNushellIntegration = mkEnableOption "homebrew nushell integration" // {
    #     default = false;
    #   };
    # };
  };

  config = {
    # nix-homebrew homebrew module
    # Manages homebrew installation
    nix-homebrew = {
      user = userName;
      enable = true;
      enableZshIntegration = true;
      taps = {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
        "homebrew/homebrew-bundle" = homebrew-bundle;
      };
      mutableTaps = false;
      autoMigrate = true;
    };

    # Homebrew shell integration
    # home-manager.users.${userName}.programs = {
    #   zsh.initExtra = mkIf cfg.enableZshIntegration /*bash*/ ''
    #     eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
    #   '';
    #
    #   bash.initExtra = mkIf cfg.enableBashIntegration /*bash*/ ''
    #     eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
    #   '';
    #
    #   fish.interactiveShellInit = mkIf cfg.enableFishIntegration /*bash*/ ''
    #     eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
    #   '';
    #
    #   # https://www.nushell.sh/book/configuration.html#homebrew
    #   # https://reimbar.org/dev/nushell/
    #   nushell.extraEnv = mkIf cfg.enableFishIntegration /*bash*/ ''
    #     # $env.PATH = ($env.PATH | split row (char esep) | prepend '/opt/homebrew/bin') 
    #     use std "path add"
    #     path add /opt/homebrew/bin
    #   '';
    # };

    # nix-darwin homebrew module
    # Manages homebrew packages
    homebrew = {
      enable = true;
      onActivation.cleanup = "uninstall";

      # Fixes nix-darwin trying to untap nix-homebrew taps 
      # when onActivation.cleanup = uninstall/zap is set
      # https://github.com/zhaofengli/nix-homebrew/issues/5
      taps = builtins.attrNames config.nix-homebrew.taps;

      casks = [
        # Development Tools
        # "homebrew/cask/docker"
        # "visual-studio-code"
        "visual-studio-code@insiders"

        # Communication Tools
        # "discord"
        # "notion"
        # "slack"
        # "telegram"
        # "zoom"

        # Utility Tools
        # "syncthing"

        # Entertainment Tools
        # "iina" # Video player

        # Productivity Tools
        "raycast"

        # Browsers
        "google-chrome"
        # "arc" # Arc browser
      ];

      # Mac App Store Apps
      # These app IDs are from using the mas CLI app
      # $ nix shell nixpkgs#mas
      # $ mas search <app name>
      #
      # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
      # you may receive an error message "Redownload Unavailable with This Apple ID".
      # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)
      # masApps = {
      #   "1password" = 1333542190;
      #   "wireguard" = 1451685025;
      # };
    };
  };
}
