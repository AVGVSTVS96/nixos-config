{ lib, config, variables, ... }:

{
  imports = [
    ./nix.nix
    ./secrets.nix
    ./shells/zsh.nix
    ./shells/fish.nix
  ];

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

  config = {
    # TODO: Find a better place to put this, maybe a new `common.nix` module 
    # or keep it here and move the above options to a new `options.nix` module
    environment.variables = {
      EDITOR = "nvim";
    };

    home-manager.users.${variables.userName} = {
      home.sessionVariables = {
        ANTHROPIC_API_KEY = "`cat ${config.age.secrets.anthropic.path}`";
        OPENAI_API_KEY = "`cat ${config.age.secrets.openai.path}`";
      };
    };
  };
}
