{ variables, inputs, pkgs, ... }:
let
  inherit (variables) userName;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  # This file configures and references secrets in the `secrets` directory
  #
  # The primary.age file is made available to nixos here
  # This can be referenced in the nixos config with /run/agenix/primary
  # TODO: See if config.age.secretsDir/primary also works
  age.secrets = {
    primary = {
      file = ../../secrets/primary.age;

      # Makes file accessible by user
      owner = userName;
      mode = "600";
    };

    graphite = {
      file = ../../secrets/graphite.age;

      # Path to place decrypted file
      # This is necessary because there is no way to 
      # configure graphite in nixos, so we encrpyt and 
      # place the full file where graphite expects it
      path = if isDarwin 
        then "/Users/${variables.userName}/.config/graphite/user_config"
        else "/home/${variables.userName}/.config/graphite/user_config";
      owner = userName;
      mode = "600";
    };
  };

  # Import the ragenix module in home-manager in addition to nixos configurations
  home-manager.users.${variables.userName} = {
    imports = [ inputs.ragenix.homeManagerModules.age ];
  };

  # Add ragenix cli to global ssystem packages
  environment.systemPackages = with pkgs; [ inputs.ragenix.packages.${system}.ragenix ];
