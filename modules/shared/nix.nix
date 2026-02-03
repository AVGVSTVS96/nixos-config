{ pkgs, variables, lib, ... }:

let
  inherit (variables) userName;
in
{
  nix = {
    package = pkgs.nix;
    settings.allowed-users = [ "${userName}" ];
    settings.trusted-users = [
      "@admin"
      "${userName}"
    ];

    gc =
      {
        automatic = true;
        options = "--delete-older-than 30d";
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        interval = { Weekday = 0; Hour = 2; Minute = 0; };
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        dates = "weekly";
      };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };

    overlays =
      let
        overlaysDir = ../../overlays;
        files = builtins.attrNames (builtins.readDir overlaysDir);
        nixFiles = builtins.filter (f: builtins.match ".*\\.nix" f != null) files;
      in
      map (f: import (overlaysDir + "/${f}")) nixFiles;
  };
}
