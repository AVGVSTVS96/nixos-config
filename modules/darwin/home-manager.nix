{ config, pkgs, inputs, variables, ... }:

let
  inherit (variables) userName;
in
{
  imports = [ 
    ./dock
    ./packages.nix
  ];

  home-manager = {
    extraSpecialArgs = { inherit variables inputs; };
    useGlobalPkgs = true;
    backupFileExtension = "hm-bak";
    users.${userName} =
      { pkgs, config, lib, ... }: {
        home = {
          enableNixpkgsReleaseCheck = false;
          stateVersion = "23.11";
        };
        imports = [
          ./files.nix
          ../shared/programs.nix
        ];
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
      path = "${config.users.users.${userName}.home}/.local/share/";
      section = "others";
      options = "--sort name --view grid --display folder";
    }
    {
      path = "${config.users.users.${userName}.home}/Downloads";
      section = "others";
      options = "--sort dateadded --view grid --display stack";
    }
  ];

}
