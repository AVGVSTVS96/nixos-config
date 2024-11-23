{ lib, ... }:
{
  options.shells = {
    # Provides `shells.activeShell` option used in ./shells/*
    # Each shell module sets `shells.activeShell` to the shell name
    #
    # Programs can enable shell specific options with `shells.activeShell`:
    # `enableFishIntegration = config.shells.activeShell == "fish";`
    #
    activeShell = lib.mkOption {
      type = lib.types.enum [ "none" "zsh" "fish" "bash" ];
      default = "none";
      description = "Currently active shell";
    };
  };
}
