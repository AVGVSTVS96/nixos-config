{ config, variables, ... }:

{
  imports = [
    ./nix.nix
    ./options.nix
    ./secrets.nix
    ./shells/zsh.nix
    ./shells/fish.nix
  ];

  # TODO: look for way to add env vars as a file in nix
  environment.variables = {
    EDITOR = "nvim";
  };

  home-manager.users.${variables.userName} = {
    home.sessionVariables = {
      ANTHROPIC_API_KEY = "`cat ${config.age.secrets.anthropic.path}`";
      OPENAI_API_KEY = "`cat ${config.age.secrets.openai.path}`";
    };
  };

}
