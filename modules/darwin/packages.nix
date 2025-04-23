{ pkgs, variables, ... }:
let
  inherit (variables) userName;
in
{
  imports = [ ../shared/packages.nix ];

  home-manager.users.${userName} = {
    home.packages = with pkgs; [ dockutil ];
  };
}
