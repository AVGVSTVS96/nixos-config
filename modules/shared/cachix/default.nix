{ pkgs, lib, ... }:
{
  nix.settings = {
    # cache.nixos.org is included by default
    extra-substituters = [
      "https://cache.garnix.io"           # aarch64-darwin builds
      "https://nix-community.cachix.org"  # home-manager, community projects
      "https://yaxitech.cachix.org"       # ragenix
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "yaxitech.cachix.org-1:PFNhlI60xbzG/d/c+N0mbcro3J8z1Rvm2+t1aU/4Kko="
    ];
  };
}
