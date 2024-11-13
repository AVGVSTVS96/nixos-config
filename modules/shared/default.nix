{ lib, ... }:

{
  imports = [
    ./nix.nix
    ./shells/zsh.nix
    ./shells/fish.nix
  ];

  options.shells = {
    activeShell = lib.mkOption {
      type = lib.types.enum [ "none" "zsh" "fish" "bash" ];
      default = "none";
      description = "Currently active shell";
    };
  };
}
