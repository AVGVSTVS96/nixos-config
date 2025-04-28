{ pkgs, variables, ... }:

let
  inherit (variables) userName;
  hostName = variables.hostName.darwin;
  localHostName = hostName;
in
{
  imports = [
    ../../modules/darwin/dock
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared/cachix
    ../../modules/shared
  ];

  shells.zsh.enable = true;
  shells.fish.enable = false;

  users.users.${userName} = {
    name = "${userName}";
    home = "/Users/${userName}";
    isHidden = false;
  };

  # Auto upgrade nix package and the daemon service.
  # INFO:: nix-darwin now manages nix-daemon
  # unconditionally when `nix.enable` is on.
  # services.nix-daemon.enable = true;
  # nix.enable = false;

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  # inherit sets options to the variable with the same name
  networking = { inherit hostName localHostName; };

  environment.systemPackages = with pkgs; [ git ];

  # MacOS settings
  system = {
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 1;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.swipescrolldirection" = false;
      };

      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 48;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
