{ pkgs, variables, lib, ... }:

let
  inherit (variables) userName;
in
{
  nix = {
    package = pkgs.nix;
    settings.allowed-users = [ "${userName}" ];
    settings.trusted-users = [ "@admin" "${userName}" ];

    # gc = lib.mkMerge [
    #   {
    #     automatic = true;
    #     options = "--delete-older-than 30d";
    #   }
    #   (lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    #     user = "root";
    #     interval = { Weekday = 0; Hour = 2; Minute = 0; };
    #   })
    #   (lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    #     dates = "weekly";
    #   })
    # ];

    gc =
      {
        automatic = true;
        options = "--delete-older-than 30d";
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        user = "root";
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

    overlays = (
      # Apply each overlay found in the /overlays directory
      let
        path = ../../overlays;
      in
      with builtins;
      map (n: import (path + ("/" + n))) (
        filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
          attrNames (readDir path)
        )
      )

      # Example for getting overlay as tarball from github
      # ++ [(import (builtins.fetchTarball {
      #          url = "https://github.com/dustinlyons/emacs-overlay/archive/refs/heads/master.tar.gz";
      #          sha256 = "06413w510jmld20i4lik9b36cfafm501864yq8k4vxl5r4hn0j0h";
      #      }))] 
    );
  };
}
