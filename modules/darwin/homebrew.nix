{ variables, inputs, config, ... }:
let
  inherit (variables) userName;
  inherit (inputs) homebrew-bundle homebrew-core homebrew-cask;
  inherit (lib) mkIf mkEnableOption;
in
{
  # TODO: Add homebrew shell integration
  # https://github.com/zhaofengli/nix-homebrew/pull/39

  # nix-homebrew homebrew module
  # Manages homebrew installation
  nix-homebrew = {
    user = userName;
    enable = true;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
    };
    mutableTaps = false;
    autoMigrate = true;
  };

  # nix-darwin homebrew module
  # Manages homebrew packages
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";

    # Fix nix-darwin trying to untap nix-homebrew taps when uninstall is set
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
}
