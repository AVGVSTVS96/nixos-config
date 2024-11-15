
{ variables, inputs, pkgs, ... }:
let
  inherit (variables) userName;
in
{
  # This file configures and references secrets in the `secrets` directory
  #
  # The primary.age file is made available to nixos here
  # This can be referenced in the nixos config with /run/agenix/primary
  age.secrets.primary = {
    file = ../../secrets/primary.age;

    # Makes file accessible by user
    owner = userName;
    mode = "600";
  };

  # Import the ragenix module in home-manager in addition to nixos configurations
  home-manager.users.${variables.userName} = {
    imports = [ inputs.ragenix.homeManagerModules.age ];
  };

  # Add ragenix cli to global ssystem packages
  environment.systemPackages = with pkgs; [ inputs.ragenix.packages.${system}.ragenix ];
