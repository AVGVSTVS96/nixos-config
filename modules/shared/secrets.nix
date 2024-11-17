{ variables, inputs, pkgs, config, ... }:
let
  inherit (variables) userName;
  homeDir = config.users.users.${userName}.home;
in
  {
  # Configure agenix secrets for nix config. Access via:
  # `config.age.secrets.<name>.path` or `/run/agenix/<name>`

  age = {
    # Path to find identity (private) keys used to decrypt secrets
    # These correspond to recipient (public) keys in secrets.nix
    # Defaults to ~/.ssh/id_ed25519, ~/.ssh/id_rsa
    #
    # NOTE: Use strings ("/path/to/id_rsa"), not nix paths (../path/to/id_rsa),
    #       to avoid private keys being copied to the nix store
    #
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
        path = "${homeDir}/.config/graphite/user_config"; # decrypt secret to this location
        owner = userName;
        mode = "600";
      };

      anthropic = {
        file = ../../secrets/anthropic.age;
        owner = userName;
        mode = "600";
      };

      openai = {
        file = ../../secrets/openai.age;
        owner = userName;
        mode = "600";
      };
    };
  };

  # Add agenix cli
  environment.systemPackages = with pkgs; [
    inputs.ragenix.packages.${system}.ragenix
  ];

  # NOTE: This may only be needed when defining secrets in home-manager
  # home-manager.users.${userName} = {
  #   imports = [ inputs.ragenix.homeManagerModules.age ];
  # };
}
