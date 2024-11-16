{ variables, inputs, pkgs, config, ... }:
let
  inherit (variables) userName;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  homeDir = config.users.users.${userName}.home;
in
  {
  # Configure agenix secrets for nix config. Access via:
  # `config.age.secrets.<name>.path` or `/run/agenix/<name>`

  age = {
    # This is the master key - it is used to decrypt all other keys
    # This key is copied to the `.secrets` directory on the target system
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "${homeDir}/.secrets/master.age.key"
    ];
    
    secrets = {
      primary = {
        file = ../../secrets/primary.age;
        owner = userName;
        mode = "600";
      };

      graphite = {
        file = ../../secrets/graphite.age;

        # Path to place decrypted file
        # This is necessary because there is no way to
        # configure graphite in nixos, so we decrpyt and
        # place the full file where graphite expects it
        path = if isDarwin
          then "${homeDir}/.config/graphite/user_config"
          else "${homeDir}/.config/graphite/user_config";
        owner = userName;
        mode = "600";
      };
    };
  };


  # Ensure ragenix is available in home-manager
  home-manager.users.${variables.userName} = {
    imports = [ inputs.ragenix.homeManagerModules.age ];
  };

  # Add ragenix cli to global system packages
  environment.systemPackages = with pkgs; [
    inputs.ragenix.packages.${system}.ragenix
  ];
