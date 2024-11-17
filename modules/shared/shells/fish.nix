{ pkgs, lib, config, variables, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge optionalAttrs;
  inherit (variables) userName;
  fish = config.shells.fish;
in
{
  # Enable fish with:
  # `shells.fish.enable = true;`

  # Set shell per host in:
  # hosts/<host>/default.nix or modules/<host>/home-manager.nix

  # Set shell for all hosts in:
  # modules/shared/default.nix

  options.shells.fish = {
    enable = mkEnableOption "fish shell";
  };

  config = mkIf fish.enable {

    # Programs can conditionally enable shell specific integrations
    # by accessing `shells.activeShell`. For example:
    # `enableZshIntegration = config.shells.activeShell == "zsh";`
    shells.activeShell = "fish";

    home-manager.users.${userName}.programs.fish = {
      enable = true;
      shellAbbrs = {
        # General aliases
        g   = "git";
        exz = "exec zsh";
        cl  = "clear";
        yz  = "yazi";
        lg  = "lazygit";
        # Nix aliases
        ns  = "git add . && nix run .#build-switch";
        nb  = "git add . && nix run .#build";
        # Eza aliases
        ls  = "eza --git --icons=always --color=always --long --no-user --no-permissions --no-filesize --no-time";
        lsa = "eza --git --icons=always --color=always --long --no-user --no-permissions --no-filesize --no-time --all";
        l   = "eza --git --icons=always --color=always --long --no-filesize";
        la  = "eza --git --icons=always --color=always --long --no-filesize -all";
        lt  = "eza --git --icons=always --color=always --long --no-filesize -all --tree --level=2";
        lt2 = "eza --git --icons=always --color=always --long --no-filesize -all --tree --level=3";
        lt3 = "eza --git --icons=always --color=always --long --no-filesize -all --tree --level=4";
        ltg = "eza --git --icons=always --color=always --long --no-filesize --tree --git-ignore";
      };
    };

    # Set nix managed system shell
    environment.shells = [ pkgs.fish ];
    programs.fish.enable = true;

    # Make sure nix managed shell is used by default
    users = mkMerge [
      { users.${userName}.shell = pkgs.fish; }

      (optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        # knownUsers may not be the best way to do this
        # setup nix managed shell in nix-darwin
        # https://github.com/LnL7/nix-darwin/issues/811#issuecomment-2227568956
        knownUsers = [ userName ];
        users.${userName}.uid = 501;
      })
    ];
  };
}
