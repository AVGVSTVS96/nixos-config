{ pkgs, variables, ... }:
let
  inherit (variables) userName;
in
{
  imports = [ ../shared/packages.nix ];

  home-manager.users.${userName} = {
    home.packages = with pkgs; [
      # TODO: Re-enable when swift builds on nixpkgs-unstable (see nixpkgs#343210)
      # dockutil
    ];
  };
}
