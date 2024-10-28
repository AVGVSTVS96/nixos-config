{ config, pkgs, tokyonight, variables, ... }:

let
  user = variables.user;
in
{
  imports = [ ./dock ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };
    # onActivation.cleanup = "uninstall";

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
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

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        stateVersion = "23.11";
      };
      imports = [
        tokyonight.homeManagerModules.default
        ./files.nix
        ./packages.nix
      ];
      tokyonight.enable = true;
      tokyonight.style = "night";
      programs = { } // import ../shared/home-manager.nix { inherit config pkgs lib variables; };
      xdg.enable = true;
      # Marked broken Oct 20, 2022 check later to remove this workaround
      # https://github.com/nix-community/home-manager/issues/3344
      # Sept 13, 2024 - This should be fine, no issues reported in last 1.5yrs
      # manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "/System/Applications/Launchpad.app"; }
    { path = "/Applications/Visual Studio Code - Insiders.app/"; }
    { path = "/Applications/Google Chrome.app/"; }
    { path = "/System/Applications/Messages.app/"; }
    { path = "/System/Applications/Music.app/"; }
    { path = "/System/Applications/News.app/"; }
    { path = "/System/Applications/Photos.app/"; }
    { path = "/System/Applications/TV.app/"; }
    { path = "/System/Applications/Home.app/"; }
    { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
    { path = "${pkgs.wezterm}/Applications/WezTerm.app/"; }
    { path = "/System/Applications/Utilities/Terminal.app/"; }
    { path = "/System/Applications/Utilities/Activity Monitor.app/"; }
    { path = "/System/Applications/System Settings.app/"; }
    {
      path = "${config.users.users.${user}.home}/.local/share/";
      section = "others";
      options = "--sort name --view grid --display folder";
    }
    {
      path = "${config.users.users.${user}.home}/Downloads";
      section = "others";
      options = "--sort dateadded --view grid --display stack";
    }
  ];

}
